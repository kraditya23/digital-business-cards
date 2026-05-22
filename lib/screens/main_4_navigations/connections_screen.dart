import 'package:card_app/screens/connection_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_app/providers/connections_provider.dart';
import 'package:card_app/screens/qr_scanner_screen.dart';
import 'package:card_app/screens/profile_page.dart';

class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionsAsync = ref.watch(connectionsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        centerTitle: false,
        title: const Text(
          'CONNECTIONS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.1,
            color: Colors.black87,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              label: Text('New'),
              icon: Icon(Icons.person_add),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => QrScannerScreen(
                          onScanned: (uid, username) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ProfilePage(uid: uid, profileUsername: username),
                              ),
                            );
                          },
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Connections List
          Expanded(
            child: connectionsAsync.when(
              data: (connections) {
                // Filter by name (case insensitive)
                final filtered =
                    _searchQuery.isEmpty
                        ? connections
                        : connections
                            .where(
                              (c) => c.name.toLowerCase().contains(
                                (_searchQuery.toLowerCase()),
                              ),
                            )
                            .toList();
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Connections found',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final conn = filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage:
                            (conn.profilePicUrl != null &&
                                    conn.profilePicUrl!.isNotEmpty)
                                ? NetworkImage(conn.profilePicUrl!)
                                : AssetImage(
                                      'assets/user_profile/default_avatar.jpg',
                                    )
                                    as ImageProvider,
                        backgroundColor: Colors.grey[250],
                      ),
                      title: Text(
                        conn.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          ((conn.jobTitle?.isNotEmpty ?? false) ||
                                  (conn.organisation?.isNotEmpty ?? false))
                              ? Text(
                                [
                                      if (conn.jobTitle?.isNotEmpty ?? false)
                                        conn.jobTitle,
                                      if (conn.organisation?.isNotEmpty ??
                                          false)
                                        conn.organisation,
                                    ]
                                    .where((e) => e != null && e.isNotEmpty)
                                    .join(' • '),
                              )
                              : Text(
                                'Connected since: ${conn.since!.toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ConnectionProfilePage(
                                  uid: conn.uid,
                                  profileUsername: conn.username,
                                  fromConnections: true,
                                ),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder:
                      (context, index) => const Divider(
                        thickness: 0.5,
                        indent: 50 + 16,
                        endIndent: 16,
                        height: 0,
                        color: Colors.black26,
                      ),
                );
              },
              error: (e, st) => Center(child: Text('Error: $e')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
