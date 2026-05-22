import 'dart:async';
import 'package:card_app/utilities/firestore_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_app/models/user_data.dart';

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserData?>>(
  (ref) {
    return UserNotifier();
  },
);

class UserNotifier extends StateNotifier<AsyncValue<UserData?>> {
  late final StreamSubscription<User?> _authSub;

  UserNotifier() : super(const AsyncValue.loading()) {
    loadUser();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) {
      loadUser();
    });
  }

  // Add this:
  void getUserData() {
    loadUser();
  }

  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = AsyncValue.data(null);
      return;
    }
    final uid = user.uid;

    try {
      final rootDoc = await FirestorePaths.userRoot(uid).get();

      if (!rootDoc.exists || !rootDoc.data()!.containsKey('defaultProfile')) {
        state = AsyncValue.data(null);
        return;
      }

      final defaultProfile = rootDoc.data()!['defaultProfile'] as String;
      final profileRef = FirestorePaths.userProfile(uid, defaultProfile);
      final profileDoc = await profileRef.get();

      if (!profileDoc.exists || profileDoc.data() == null) {
        state = AsyncValue.data(null);
        return;
      }

      final userData = UserData.fromMap(profileDoc.data()!);
      state = AsyncValue.data(userData);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveUser(String username) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 1. Claim the username
        final mappingRef = FirestorePaths.usernameMapping(username);
        final mappingSnap = await transaction.get(mappingRef);
        if (mappingSnap.exists) {
          throw Exception('Username already taken!');
        }
        transaction.set(mappingRef, {'uid': uid});

        // 2. Create the profile doc under users/{uid}/profiles/{username}
        final profileRef = FirestorePaths.userProfile(uid, username);
        transaction.set(profileRef, {'username': username, 'uid': uid});

        // 3. Setting defaultProfile on the user root, merging so
        // we dont overwrite other fields
        final rootRef = FirestorePaths.userRoot(uid);
        transaction.set(rootRef, {
          'defaultProfile': username,
        }, SetOptions(merge: true));
      });

      // Once transaction succeeds, update local state in one shot
      state = AsyncValue.data(UserData(uid: uid, username: username));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateContactInfo(
    String name,
    String profilePicUrl,
    String coverPicUrl,
    String jobTitle,
    String organisation,
    String location,
    List<String> phoneNumbers,
    List<String> emails,
  ) async {
    final currentUser = state.value;
    if (currentUser == null) return;
    final uid = currentUser.uid;

    try {
      final docRef = FirestorePaths.userProfile(uid, currentUser.username);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'name': name,
          'profilePicUrl': profilePicUrl,
          'coverPicUrl': coverPicUrl,
          'jobTitle': jobTitle,
          'organisation': organisation,
          'location': location,
          'phoneNumbers': phoneNumbers,
          'emails': emails,
        });

        // Create new UserData with updated contact info, preserving all other fields
        final updatedUser = currentUser.copyWith(
          name: name,
          profilePicUrl: profilePicUrl,
          coverPicUrl: coverPicUrl,
          jobTitle: jobTitle,
          organisation: organisation,
          phoneNumbers: phoneNumbers,
          emails: emails,
        );

        state = AsyncValue.data(updatedUser);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Method to update links section ONLY
  Future<void> updateLinksSection({
    required List<String> linksText,
    required List<String> linkUrl,
    String? linkSectionHeader,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;
    final uid = currentUser.uid;

    try {
      final docRef = FirestorePaths.userProfile(uid, currentUser.username);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'linkSectionHeader':
              linkSectionHeader ?? currentUser.linkSectionHeader,
          'linksText': linksText,
          'linkUrl': linkUrl,
        });

        // Update local state with new links data, keep other fields unchanged
        final updatedUser = currentUser.copyWith(
          linkSectionHeader: linkSectionHeader ?? currentUser.linkSectionHeader,
          linksText: linksText,
          linkUrl: linkUrl,
        );

        state = AsyncValue.data(updatedUser);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAboutMe(String aboutMeText) async {
    final currentUser = state.value;
    if (currentUser == null) return;
    final uid = currentUser.uid;

    try {
      final docRef = FirestorePaths.userProfile(uid, currentUser.username);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({'aboutMe': aboutMeText});

        // Update local state with new aboutMe text, keep other fields unchanged
        final updatedUser = currentUser.copyWith(aboutMe: aboutMeText);

        state = AsyncValue.data(updatedUser);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSocialIcons({
    required List<String> socialNames,
    required List<String> socialUrls,
    required List<String> socialIcons,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;
    final uid = currentUser.uid;

    try {
      final docRef = FirestorePaths.userProfile(uid, currentUser.username);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'socialNames': socialNames,
          'socialUrl': socialUrls,
          'socialIcons': socialIcons,
        });

        // Update local state with new social data, keep other fields unchanged
        final updatedUser = currentUser.copyWith(
          socialNames: socialNames,
          socialUrl: socialUrls,
          socialIcons: socialIcons,
        );

        state = AsyncValue.data(updatedUser);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSchedulingLink(String newLink) async {
    final currentUser = state.value;
    if (currentUser == null) return;
    final uid = currentUser.uid;

    try {
      final docRef = FirestorePaths.userProfile(uid, currentUser.username);

      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.update({'scheduling': newLink});

        final updatedUser = currentUser.copyWith(scheduling: newLink);

        state = AsyncValue.data(updatedUser);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Additional helper methods for better state management
  Future<void> refreshUser() async {
    await loadUser();
  }

  void clearUser() {
    state = const AsyncValue.data(null);
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
