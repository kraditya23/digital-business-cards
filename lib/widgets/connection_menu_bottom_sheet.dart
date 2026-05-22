import 'package:card_app/models/user_data.dart';
import 'package:card_app/services/native_contacts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:ui';

class ConnectionMenuBottomSheet extends StatefulWidget {
  final String connectionUsername;
  final UserData userData;

  const ConnectionMenuBottomSheet({
    super.key,
    required this.connectionUsername,
    required this.userData,
  });

  @override
  State<ConnectionMenuBottomSheet> createState() =>
      _ConnectionMenuBottomSheetState();
}

class _ConnectionMenuBottomSheetState extends State<ConnectionMenuBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.45,
        maxChildSize: 0.5,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'Manage Connection',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.download),
                title: Text('Save Contact to phone'),
                onTap: () async {
                  Navigator.pop(context);

                  final contactMap = buildContactMap(widget.userData);

                  final success = await NativeContacts.addOrUpdateContact(
                    contactMap,
                  );

                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open native "Add Contact" UI'),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.note_add),
                title: Text('Add Notes'),
                onTap: () {
                  // TODO: Implement Add Notes action
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Delete Connection',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete connection'),
                          content: const Text(
                            'Are you sure you want to delete this connection?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                  if (confirm == true) {
                    // Show loading overlay
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) => PopScope(
                            canPop: false,
                            onPopInvokedWithResult: (didPop, details) {},
                            child: Stack(
                              children: [
                                BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 3,
                                    sigmaY: 3,
                                  ),
                                  child: Container(
                                    color: Colors.black.withAlpha(
                                      (0.2 * 255).toInt(),
                                    ),
                                  ),
                                ),
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ],
                            ),
                          ),
                    );
                    try {
                      await FirebaseFunctions.instance
                          .httpsCallable('deleteConnection')
                          .call({
                            'connectionUsername': widget.connectionUsername,
                          });
                      Navigator.pop(context); // Remove loading overlay
                      Navigator.pop(
                        context,
                        true,
                      ); // Close bottom sheet and return true
                    } catch (e) {
                      Navigator.pop(context); // Remove loading overlay
                      Navigator.pop(context, false); // Close bottom sheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to delete connection"),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

Map<String, dynamic> buildContactMap(UserData data) {
  // 1. Build the "websites" list: each entry is a Map<String, String>
  final List<Map<String, String>> websites = [];

  // a. "links"
  if (data.linkUrl != null) {
    for (int i = 0; i < data.linkUrl!.length; i++) {
      final rawUrl = data.linkUrl![i].trim();
      if (rawUrl.isEmpty) continue;
      final customLabel = data.linksText![i].trim();

      websites.add({'url': rawUrl, 'label': customLabel});
    }
  }

  // b. "social"
  if (data.socialUrl != null) {
    for (int i = 0; i < data.socialUrl!.length; i++) {
      final rawUrl = data.socialUrl![i].trim();
      if (rawUrl.isEmpty) continue;
      final customLabel = data.socialNames![i].trim();

      websites.add({'url': rawUrl, 'label': customLabel});
    }
  }

  // c. "scheduling link"
  if (data.scheduling != null && data.scheduling!.trim().isNotEmpty) {
    websites.add({'url': data.scheduling!.trim(), 'label': 'Scheduling'});
  }

  // 2. building the final map
  final contactMap = <String, dynamic>{
    'fullName': data.name?.trim() ?? data.username,
    'phones': data.phoneNumbers ?? <String>[],
    'emails': data.emails ?? <String>[],
    'organisation': data.organisation ?? '',
    'jobTitle': data.jobTitle ?? '',
    'websites': websites,
    'location': data.location ?? '',
    'aboutMe': data.aboutMe ?? '',
  };

  return contactMap;
}
