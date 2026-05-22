import 'package:flutter/material.dart';
import 'main_4_navigations/your_card_screen.dart';
import 'main_4_navigations/settings_screen.dart';
import 'main_4_navigations/connections_screen.dart';
// import 'main_4_navigations/home_screen.dart';
import 'package:card_app/utilities/app_colors.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    YourCardScreen(),
    ConnectionsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.shifting,
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color.fromARGB(255, 82, 82, 91),
        items: const [
          // BottomNavigationBarItem(
          //   icon: ImageIcon(
          //     AssetImage('assets/icons/navigation_icons/home.png'),
          //   ),
          //   label: 'Home',
          // ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icons/navigation_icons/your_card.png'),
            ),
            label: 'Your Card',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icons/navigation_icons/connections.png'),
            ),
            label: 'Connections',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/icons/navigation_icons/settings.png'),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
