import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_app/providers/user_provider.dart';
import 'package:card_app/widgets/snackbars.dart';

class EditSocialIconsScreen extends ConsumerStatefulWidget {
  const EditSocialIconsScreen({super.key});

  @override
  ConsumerState<EditSocialIconsScreen> createState() =>
      _EditSocialIconsScreenState();
}

class _EditSocialIconsScreenState extends ConsumerState<EditSocialIconsScreen> {
  late List<String> socialNames;
  late List<TextEditingController> socialControllers;
  late List<String> iconAssetPaths;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value;

    socialNames = [
      'Whatsapp',
      'Instagram',
      'Telegram',
      'YouTube',
      'Facebook',
      'LinkedIn',
      'X',
      'Reddit',
      'Discord',
    ];
    iconAssetPaths = [
      'assets/icons/social_icons/whatsapp.png',
      'assets/icons/social_icons/instagram.png',
      'assets/icons/social_icons/telegram.png',
      'assets/icons/social_icons/youtube.png',
      'assets/icons/social_icons/facebook.png',
      'assets/icons/social_icons/linkedin.png',
      'assets/icons/social_icons/x.png',
      'assets/icons/social_icons/reddit.png',
      'assets/icons/social_icons/discord.png',
    ];

    // Type-safely cast user?.socialUrl to Map<String, dynamic> and then to Map<String, String>

    // Type-safely cast user?.socialUrl to Map<String, String>
    // Handle user?.socialUrl which appears to be a List<String> or Map
    // Handle user?.socialUrl which is a List<String>
    Map<String, String> userSocialUrls = {};
    final rawSocialUrl = user?.socialUrl;

    if (rawSocialUrl != null) {
      // Map the list items to social names by index position
      for (int i = 0; i < rawSocialUrl.length && i < socialNames.length; i++) {
        final url = rawSocialUrl[i].toString();
        if (url.isNotEmpty) {
          userSocialUrls[socialNames[i]] = url;
        }
      }
    }

    socialControllers = List.generate(socialNames.length, (i) {
      final name = socialNames[i];
      String value = '';
      if (userSocialUrls.containsKey(name)) {
        value =
            name == 'Instagram'
                ? userSocialUrls[name]!
                    .split('/')
                    .last // for Instagram username
                : userSocialUrls[name]!;
      }
      return TextEditingController(text: value);
    });
  }

  @override
  void dispose() {
    for (final controller in socialControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildSocialRow(
    String name,
    String iconAssetPath,
    TextEditingController controller,
    int index,
  ) {
    final urlEntered = controller.text.trim().isNotEmpty;

    Widget iconWidget;
    if (urlEntered) {
      iconWidget = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(iconAssetPath, width: 30, height: 30),
      );
    } else {
      iconWidget = const SizedBox(width: 46); // Keeps row alignment
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText:
                        name == 'Instagram' ? 'Enter Username' : 'Enter URL',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  onChanged: (value) {
                    setState(() {}); // So the icon shows/hides as you type
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Social Icons'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add or edit your social media URLs below.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: socialNames.length,
                itemBuilder: (context, index) {
                  return _buildSocialRow(
                    socialNames[index],
                    iconAssetPaths[index],
                    socialControllers[index],
                    index,
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  try {
                    final userNotifier = ref.read(userProvider.notifier);
                    final urls =
                        socialControllers.map((c) => c.text.trim()).toList();
                    await userNotifier.updateSocialIcons(
                      socialNames: socialNames,
                      socialUrls: urls,
                      socialIcons: socialNames,
                    );

                    context.showSuccessSnackBar(
                      message: 'Social URLs submitted and saved!',
                    );
                  } catch (e) {
                    context.showErrorSnackBar(
                      message: 'Failed to save social URLs: ${e.toString()}',
                    );
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
