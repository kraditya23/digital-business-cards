import 'package:card_app/screens/editing_card/edit_content_screen/scheduling.dart';
import 'package:card_app/screens/editing_card/edit_content_screen/about_me.dart';
import 'package:card_app/screens/editing_card/edit_content_screen/links.dart';
import 'package:card_app/screens/editing_card/edit_content_screen/social_icons.dart';
import 'package:flutter/material.dart';
import 'card_button.dart';

class EditContentsScreen extends StatelessWidget {
  const EditContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose Contents to add or edit')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              buildCardButton(
                iconAdress: 'assets/icons/editing_card/link.png',
                title: 'Links',
                subtitle: 'Add your links to the page',
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LinksPage()),
                  );
                },
                height: 130,
              ),
              buildCardButton(
                iconAdress: 'assets/icons/editing_card/about-me.png',
                title: 'About me',
                subtitle: 'Tell more about yourself',
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditAboutPage()),
                  );
                },
                height: 130,
              ),
              buildCardButton(
                iconAdress: 'assets/icons/editing_card/socials.png',
                title: 'Socials',
                subtitle: 'Add links to your social pages',
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditSocialIconsScreen(),
                    ),
                  );
                },
                height: 130,
              ),
              buildCardButton(
                iconAdress: 'assets/icons/editing_card/scheduling.png',
                title: 'Scheduling',
                subtitle: 'Add any of your Scheduling software',
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SchedulingPage()),
                  );
                },
                height: 130,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
