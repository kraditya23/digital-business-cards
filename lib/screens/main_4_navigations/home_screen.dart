// import 'package:card_app/utilities/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:card_app/screens/profile_page.dart';
// import 'package:card_app/screens/qr_scanner_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 3,
//         centerTitle: true,
//         title: const Text(
//           'HOME',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 21,
//             letterSpacing: 1.1,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Quick Actions',
//               style: TextStyle(
//                 fontSize: 21,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 18),
//             Row(
//               children: [
//                 // Edit Profile Button
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder:
//                               (_) => QrScannerScreen(
//                                 onScanned: (username) {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder:
//                                           (_) => ProfilePage(
//                                             profileUsername: username,
//                                           ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       height: 100,
//                       decoration: BoxDecoration(
//                         color: Color(0xFFF7F9FC), // Light background
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Color(0xFFE0E5EF), width: 2),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.qr_code_scanner,
//                               color: primaryColor,
//                               size: 36,
//                             ),
//                           ),
//                           const SizedBox(width: 14),
//                           const Text(
//                             'Scan QR',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 18),
//                 // Share Button
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {},
//                     child: Container(
//                       height: 100,
//                       decoration: BoxDecoration(
//                         color: Color(0xFFF7F9FC), // Light background
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Color(0xFFE0E5EF), width: 2),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.share,
//                               color: primaryColor,
//                               size: 36,
//                             ),
//                           ),
//                           const SizedBox(width: 14),
//                           const Text(
//                             'Share',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {},
//                     child: Container(
//                       height: 100,
//                       decoration: BoxDecoration(
//                         color: Color(0xFFF7F9FC), // Light background
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Color(0xFFE0E5EF), width: 2),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.poll_outlined,
//                               color: primaryColor,
//                               size: 36,
//                             ),
//                           ),
//                           const SizedBox(width: 14),
//                           const Text(
//                             'Analytics',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
