import 'package:card_app/screens/authenticate/Reset_Email_Page.dart';
import 'package:card_app/screens/authenticate/sign_up_page.dart';
import 'package:card_app/services/auth/auth_exceptions.dart';
import 'package:card_app/services/auth/auth_service.dart';
import 'package:card_app/utilities/showErrorSnackbar.dart';
import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _signInWithEmail() async {
    try {
      await AuthService.firebase().logIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = AuthService.firebase().currentUser;

      if (user?.isEmailVerified ?? false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      } else {
        await AuthService.firebase().logOut();
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Email not verified'),
                content: Text('Please verify your email before logging in.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await AuthService.firebase().sendEmailVerification();
                    },
                    child: Text('Resend Email'),
                  ),
                ],
              ),
        );
      }
    } on UserNotFoundAuthException {
      showErrorSnackbar(context, 'user-not-found');
    } on WrongPasswordAuthException {
      showErrorSnackbar(context, 'Wrong-password');
    } on InvalidEmailAuthException {
      showErrorSnackbar(context, 'Invalid-Email');
    } on GenericAuthException {
      showErrorSnackbar(context, 'Authentication Error');
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await AuthService.firebase().signInWithGoogle();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    } catch (e) {
      showErrorSnackbar(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          "Login",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be atleast 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _signInWithEmail();
                    }
                  },
                  icon: Icon(Icons.mail, size: 25),
                  label: const Text('Login with email'),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    _signInWithGoogle();
                  },
                  icon: Image.asset(
                    'assets/icons/google-sign-in.png',
                    height: 25,
                    width: 25,
                  ),
                  label: Text("Continue with Google"),
                ),
                SizedBox(height: 24),
                TextButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      ),
                  child: Text('Dont have an account? Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
