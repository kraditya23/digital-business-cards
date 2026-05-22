import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_app/providers/deeplink_user_provider.dart';
import 'package:card_app/providers/user_exists_provider.dart'; 

enum AuthState {
  loading,
  notLoggedIn,
  needsOnboarding,
  complete,
  redirectingToProfile,
  error,
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(this.ref) : super(AuthState.loading) {
    _init();
  }

  final Ref ref;
  late final StreamSubscription<User?> _authSub;

  void _init() {
    // 0) Listen to auth state changes
    _authSub = FirebaseAuth.instance.authStateChanges().listen(
      (_) => _updateState(),
    );

    // 1) Whenever the “exists” provider changes, recompute
    ref.listen<AsyncValue<bool>>(userExistsProvider, (_, __) => _updateState());

    // 2) Whenever a deep link arrives, recompute
    ref.listen<({String uid, String username})?>(deepLinkUserProvider, (_, __) => _updateState());

    // 3) Initial run
    _updateState();
  }

  void _updateState() {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // 1) If nobody’s logged in, go to login
    if (firebaseUser == null) {
      state = AuthState.notLoggedIn;
      return;
    }

    // 2) Now the user is signed in; let’s check Firestore.
    //    Read the latest AsyncValue of “does that user doc exist?”
    final existAsync = ref.watch(userExistsProvider);

    // 2a) If Firestore is still loading, stay in `loading`.
    if (existAsync.isLoading) {
      state = AuthState.loading;
      return;
    }

    // 2b) If Firestore threw an error, show error
    if (existAsync.hasError) {
      state = AuthState.error;
      return;
    }

    // 2c) At this point, Firestore is never “in flight”—it either exists or does not.
    final exists = existAsync.value!; // boolean

    // 3) If the document truly does not exist, send them to WelcomeScreen
    if (!exists) {
      state = AuthState.needsOnboarding;
      return;
    }

    // 4) If there’s a deep link pending, redirect to that profile
    final deepLinkUser = ref.watch(deepLinkUserProvider);
    if (deepLinkUser != null) {
      state = AuthState.redirectingToProfile;
      return;
    }

    // 5) Otherwise, the user is fully signed in + has a profile doc → go to AppEntry
    state = AuthState.complete;
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier(ref);
});
