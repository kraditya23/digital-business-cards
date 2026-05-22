import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/utilities/firestore_paths.dart';
import 'package:card_app/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:card_app/providers/user_provider.dart';
import 'package:card_app/widgets/user_card.dart';
import 'package:card_app/models/user_data.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String uid;
  final String profileUsername;
  final bool fromConnections;
  const ProfilePage({
    required this.uid,
    required this.profileUsername,
    this.fromConnections = false,
    super.key,
  });

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isProcessing = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    if (widget.fromConnections) {
      _isConnected = true;
    } else {
      _checkIfConnected();
    }
  }

  Future<void> _checkIfConnected() async {
    final currentUserData = ref.read(userProvider).asData?.value;
    final currentUid = currentUserData?.uid;
    final currentUsername = currentUserData?.username;
    if (currentUid == null || currentUsername == null) return;
    final doc = await FirestorePaths.userConnections(
      currentUid,
      currentUsername,
    ).doc(widget.profileUsername).get();
    if (doc.exists) {
      setState(() {
        _isConnected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserData = ref.watch(userProvider).asData?.value;
    final currentUsername = currentUserData?.username;

    final profileUserDoc = FirestorePaths.userProfile(
      widget.uid,
      widget.profileUsername,
    );

    return FutureBuilder<DocumentSnapshot>(
      future: profileUserDoc.get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading profile.')),
          );
        }
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
          appBar: AppBar(title: Text(widget.profileUsername)),
          body: SingleChildScrollView(
            child: UserCard(data: UserData.fromMap(data)),
          ),
          bottomNavigationBar:
              currentUsername != null &&
                  currentUsername != widget.profileUsername
              ? SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11.0,
                          vertical: 8.0,
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 8,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isProcessing
                                  ? Colors.grey
                                  : primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(Icons.person_add_alt),
                            label: Text(
                              _isConnected
                                  ? 'Already Connected'
                                  : (_isProcessing
                                        ? 'Processing...'
                                        : 'Exchange Contacts'),
                            ),
                            onPressed: _isProcessing
                                ? null
                                : () async {
                                    if (_isConnected) {
                                      context.showNeutralSnackBar(
                                        message:
                                            'Connection already established!',
                                        icon: Icons.check,
                                      );
                                      return;
                                    }
                                    setState(() {
                                      _isProcessing = true;
                                    });
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('connectionRequests')
                                          .add({
                                            'fromUsername': currentUsername,
                                            'toUsername':
                                                widget.profileUsername,
                                            'timeStamp':
                                                FieldValue.serverTimestamp(),
                                          });
                                      setState(() {
                                        _isConnected = true;
                                      });
                                      context.showSuccessSnackBar(
                                        message: 'Contacts Exchanged!',
                                      );
                                    } catch (e) {
                                      context.showErrorSnackBar(
                                        message: 'Error: ${e.toString()}',
                                      );
                                    }
                                    setState(() {
                                      _isProcessing = false;
                                    });
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}
