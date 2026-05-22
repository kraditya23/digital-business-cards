import 'package:card_app/providers/user_provider.dart';
import 'package:card_app/screens/app_entry.dart';
import 'package:card_app/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  const UserInfoScreen({super.key});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _saveInfo() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(userProvider.notifier).saveUser(username);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AppEntry()),
        );
      }
    } catch (e) {
      context.showErrorSnackBar(
        message: e.toString().contains('Username already taken')
            ? 'Username already taken'
            : 'Something went wrong. Please try again.',
        duration: const Duration(seconds: 2),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a username')),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _usernameController.text.trim().isEmpty
                        ? null
                        : _saveInfo,
                    child: const Text('Save'),
                  ),
          ],
        ),
      ),
    );
  }
}
