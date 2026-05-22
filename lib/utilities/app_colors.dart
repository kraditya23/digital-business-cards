import 'package:flutter/material.dart';

// Theme constants
const Color primaryColor = Color.fromARGB(
  255,
  99,
  102,
  241,
); // A deep, rich purple

const Color secondaryColor = Color(
  0xFFffd166,
); // A warm, golden yellow that complements primaryColor
const Color accentColor = Color(
  0xFF66d9ef,
); // A soft, pastel blue-green that adds contrast

const Color backgroundColor = Color(0xFFFFFFFF); // A clean, white background
const Color cardBackgroundColor = Color(
  0xFFFFFFFF,
); // A clean, white background for cards
const Color cardBorderColor = Color(
  0xFFE0E0E0,
); // A light gray border for cards

// QR code color
const Color qrColor = Color(0xFF000000); // A deep, dark black for QR codes
const Color qrBackgroundColor = Color(
  0xFFFFFFFF,
); // A clean, white background for QR codes

// Text colors
const Color textColor = Color(0xFF333333); // A dark, neutral text color
const Color textColorLight = Color(
  0xFF666666,
); // A lighter version of textColor
const Color textColorLighter = Color(
  0xFF999999,
); // An even lighter version of textColor

// Button colors
const Color buttonColor = primaryColor; // Use primaryColor for buttons
const Color buttonTextColor = Color(
  0xFFFFFFFF,
); // Use white text color for buttons
//Error Colors
const Color errorColor = Colors.redAccent;

// Theme data
ThemeData appThemeData = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColor,
  cardColor: cardBackgroundColor,

  buttonTheme: ButtonThemeData(
    buttonColor: buttonColor,
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: textColor, fontSize: 16),
    bodyMedium: TextStyle(color: textColorLight, fontSize: 14),
    labelLarge: TextStyle(color: textColorLighter, fontSize: 12),
  ),
);
