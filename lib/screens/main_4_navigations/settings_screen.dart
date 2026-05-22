import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/user_provider.dart';
import 'package:card_app/utilities/reusableDropDown.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        centerTitle: false,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.1,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SECTION 1: Name & Email with Edit Button & Border
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'User Name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.email ?? 'user@example.com',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Add edit profile logic
                        },
                        child: const Text('Edit'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECTION 2: Chevron Buttons with reduced vertical padding
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildChevronButton(context, 'Analytics', () {
                    // TODO: Analytics action
                  }),
                  _buildChevronButton(context, 'NFC Devices', () {
                    // TODO: NFC Devices action
                  }),
                  _buildChevronButton(context, 'Message Snippets', () {
                    // TODO: Message Snippets action
                  }),
                  _buildChevronButton(context, 'Notification Settings', () {
                    // TODO: Notification Settings action
                  }),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // TODO: Navigate to Terms of Use & Privacy Policy
                          },
                          child: Text(
                            "Terms of Use & Privacy Policy",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          ref.invalidate(userProvider);
                        },
                        icon: const Icon(
                          Icons.logout,
                          size: 18,
                          color: Colors.black87,
                        ),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          backgroundColor: Colors.red[400],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // SECTION 3: Dropdown Menu with slightly different white background and compact items
              ReusableDropdownMenu(
                title: 'Help & Support ',
                items: [
                  DropdownMenuItemData(
                    label: 'FAQ',
                    onTap: () {
                      // TODO: FAQ action
                    },
                  ),
                  DropdownMenuItemData(
                    label: 'Contact Us',
                    onTap: () {
                      // TODO: Contact Us action
                    },
                  ),
                  DropdownMenuItemData(
                    label: 'Delete My Account',
                    onTap: () {
                      // TODO: Delete My Account action
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChevronButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
