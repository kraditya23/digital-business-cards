import 'package:cloud_firestore/cloud_firestore.dart';

class Connection {
  final String uid;
  final String username;
  final DateTime? since;
  final String name;
  final String? profilePicUrl;
  final String? jobTitle;
  final String? organisation;

  Connection({
    required this.uid,
    required this.username,
    this.since,
    required this.name,
    this.profilePicUrl,
    this.jobTitle,
    this.organisation,
  });

  factory Connection.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Connection(
      uid: data['uid'],
      username: doc.id,
      since: data['since'] != null
          ? (data['since'] as Timestamp).toDate()
          : null,
      name: data['name'] ?? '',
      profilePicUrl: data['profilePicUrl'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      organisation: data['organisation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'since': since != null ? Timestamp.fromDate(since!) : null,
      'name': name,
      'profilePicUrl': profilePicUrl,
      'jobTitle': jobTitle,
      'organisation': organisation,
    };
  }
}
