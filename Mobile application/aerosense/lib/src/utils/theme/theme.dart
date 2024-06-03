import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TAppTheme {
  static ThemeData themeData = ThemeData(
    brightness: Brightness.dark,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.raleway(
        color: const Color(0xFF101010),
      ).copyWith(fontWeight: FontWeight.bold),
    ),
  );
}
