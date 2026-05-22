import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePaths {
  static DocumentReference<Map<String, dynamic>> userProfile(
    String uid,
    String username,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .doc(username);
  }

  static DocumentReference<Map<String, dynamic>> userRoot(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  static CollectionReference<Map<String, dynamic>> userConnections(
    String uid,
    String username,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .doc(username)
        .collection('connections');
  }

  static DocumentReference<Map<String, dynamic>> usernameMapping(
    String username,
  ) {
    return FirebaseFirestore.instance.collection('usernames').doc(username);
  }
}
