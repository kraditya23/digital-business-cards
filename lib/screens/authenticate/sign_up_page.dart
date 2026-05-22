import 'package:card_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  SignUpPage({super.key});

  Future<void> _register(BuildContext context) async {
    try {
      await AuthService.firebase().createUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // send verification email
      await AuthService.firebase().sendEmailVerification();

      // show dialog to tell user to check email
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Verify your email'),
              content: Text(
                'We have sent a verification link to your email. Please verify to continue',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      print('sign up failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
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
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register(context);
                  }
                },
                icon: Icon(Icons.mail, size: 25),
                label: const Text('Sign Up with your email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
