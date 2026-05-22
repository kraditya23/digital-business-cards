import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_app/providers/auth_state_provider.dart';
import 'package:card_app/providers/deeplink_user_provider.dart';
import 'login_page.dart';
import '../onboarding/welcome_screen.dart';
import '../app_entry.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We don’t need anything here; all logic lives in authStateProvider
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final deepLinkUser = ref.watch(deepLinkUserProvider);

    switch (authState) {
      case AuthState.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      case AuthState.notLoggedIn:
        // If FirebaseAuth says no user, show LoginPage
        return const LoginPage();

      case AuthState.error:
        // Something went wrong reading Firestore
        return Scaffold(
          body: Center(child: Text('An error occurred. Please try again.')),
        );

      case AuthState.needsOnboarding:
        // Logged in but no Firestore “user profile” → show onboarding
        return const WelcomeScreen();

      case AuthState.redirectingToProfile:
        // We have user + profile data + a deep link username
        // → redirect only once (using postFrame). After that, clear the deep link.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (deepLinkUser == null) return;
          final targetRoute =
              '/profile/${deepLinkUser.uid}/${deepLinkUser.username}';
          // If we aren’t already on that exact route, navigate & clear the deep link
          if (ModalRoute.of(context)?.settings.name != targetRoute) {
            Navigator.of(context).pushReplacementNamed(targetRoute).then((_) {
              ref.read(deepLinkUserProvider.notifier).clear();
            });
          } else {
            // Already on the right page: just clear the deep link so we don’t loop forever
            ref.read(deepLinkUserProvider.notifier).clear();
          }
        });
        // While we’re “redirecting,” show an empty container (or a spinner, your choice)
        return const Scaffold(body: Center(child: SizedBox()));

      case AuthState.complete:
        // Logged in, profile data exists, and no deep link pending → show main app
        return const AppEntry();
    }
  }
}
