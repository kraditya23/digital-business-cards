import 'package:card_app/utilities/firestore_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_provider.dart';
import 'package:card_app/models/connection_model.dart';

final connectionsProvider = StreamProvider<List<Connection>>((ref) {
  final userAsync = ref.watch(userProvider);
  final user = userAsync.value;
  if (user == null) return Stream.value([]);
  return FirestorePaths.userConnections(
    user.uid,
    user.username,
  ).snapshots().map(
    (snapshot) => snapshot.docs.map((doc) => Connection.fromDoc(doc)).toList(),
  );
});
