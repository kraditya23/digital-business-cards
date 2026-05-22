import 'package:card_app/widgets/share_card_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/screens/editing_card/navigator.dart';
import 'package:card_app/widgets/user_card.dart';

class YourCardScreen extends ConsumerWidget {
  const YourCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userProvider);

    return userData.when(
      error: (e, _) => Center(child: Text('Error: $e')),
      loading:
          () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
      data: (data) {
        if (data == null) return const Center(child: Text('No data found'));

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 3,
            centerTitle: false,
            title: const Text(
              'CONNECTA CARD',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.1,
                color: Colors.black87,
              ),
            ),
            actions: [
              TextButton.icon(
                icon: ImageIcon(AssetImage('assets/icons/editing_card/edit.png'), color: primaryColor),
                label: const Text(
                  'edit',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditScreenNavigator(),
                    ),
                  );
                },
              ),
            ],
            // If you want a back button, it appears by default unless you use `automaticallyImplyLeading: false`
          ),
          body: SingleChildScrollView(child: UserCard(data: data)),

          // Share Button
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: primaryColor.withOpacity(0.3),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Share Card',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder: (context) => ShareCardBottomSheet(userData: data),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
