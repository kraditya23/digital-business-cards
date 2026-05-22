import 'package:card_app/utilities/app_colors.dart';
import 'package:flutter/material.dart';

void showErrorSnackbar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text, style: TextStyle(color: Colors.blueGrey)),
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    duration: Duration(seconds: 3),
    action: SnackBarAction(
      label: 'Dismiss',
      textColor: primaryColor,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
