import 'package:card_app/utilities/firestore_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:card_app/widgets/user_card.dart';
import 'package:card_app/models/user_data.dart';
import 'package:card_app/widgets/connection_menu_bottom_sheet.dart';

class ConnectionProfilePage extends ConsumerStatefulWidget {
  final String uid;
  final String profileUsername;
  final bool fromConnections;
  const ConnectionProfilePage({
    required this.uid,
    required this.profileUsername,
    this.fromConnections = false,
    super.key,
  });

  @override
  ConsumerState<ConnectionProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ConnectionProfilePage> {
  @override
  Widget build(BuildContext context) {
    final profileUserDoc = FirestorePaths.userProfile(
      widget.uid,
      widget.profileUsername,
    );

    return FutureBuilder<DocumentSnapshot>(
      future: profileUserDoc.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: Text('Profile')),
            body: const Center(child: Text('No user found')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.profileUsername),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () async {
                  final result = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) => ConnectionMenuBottomSheet(
                      connectionUsername: widget.profileUsername,
                      userData: UserData.fromMap(data),
                    ),
                  );
                  if (result == true) {
                    Navigator.pop(context); // Pop ConnectionProfilePage
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: UserCard(data: UserData.fromMap(data)),
          ),
        );
      },
    );
  }
}
