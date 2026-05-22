import 'package:card_app/services/auth/auth_provider.dart';
import 'package:card_app/services/auth/auth_user.dart';
import 'package:card_app/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  // current user
  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => provider.currentUser;

  // create user

  @override
  Future<AuthUser> createUser({required email, required password}) =>
      provider.createUser(email: email, password: password);

  @override
  Future<AuthUser> logIn({required String email, required String password}) =>
      provider.logIn(email: email, password: password);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<AuthUser> signInWithGoogle() => provider.signInWithGoogle();

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      provider.sendPasswordResetEmail(email: email);
}
