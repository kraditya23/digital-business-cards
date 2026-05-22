import 'package:card_app/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/screens/authenticate/auth_gate.dart';
import 'package:card_app/providers/deeplink_user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initBranchAndListener();
  }

  Future<void> _initBranchAndListener() async {
    await FlutterBranchSdk.init();
    // Whenever Branch detects a link, it writes to deepLinkUsernameProvider
    FlutterBranchSdk.listSession().listen((data) {
      if (data.containsKey('uid') && data.containsKey('username')) {
        final uid = data['uid'] as String;
        final username = data['username'] as String;
        ref.read(deepLinkUserProvider.notifier).setUser(uid, username);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business cards app',
      theme: appThemeData,
      home: const AuthGate(),
      onGenerateRoute: (settings) {
        final name = settings.name;
        if (name?.startsWith('/profile/') ?? false) {
          final parts = name!.replaceFirst('/profile/', '').split('/');
          if (parts.length == 2) {
            final uid = parts[0];
            final username = parts[1];
            return MaterialPageRoute(
              builder: (context) =>
                  ProfilePage(uid: uid, profileUsername: username),
            );
          }
        }
        // default fallback (e.g. hitting back when notLoggedIn)
        return MaterialPageRoute(builder: (context) => const AuthGate());
      },
    );
  }
}
