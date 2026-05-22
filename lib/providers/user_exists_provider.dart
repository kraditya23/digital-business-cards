import 'package:card_app/utilities/firestore_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Returns true if Firestore has a "users/{username}" doc for the current user.
final userExistsProvider = FutureProvider<bool>((ref) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser == null) {
    // Not signed in → definitely no “users/{username}” doc
    return false;
  }

  final uid = firebaseUser.uid;
  // Check if doc with uid exists, if not, the user does not exist on database yet
  final userDoc = await FirestorePaths.userRoot(uid).get();
  return userDoc.exists;
});