import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme => FlexThemeData.light(
        scheme: FlexScheme.indigo,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          cardRadius: 20.0,
          cardElevation: 0,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts.dmSans().fontFamily,
      );

  static ThemeData get darkTheme => FlexThemeData.dark(
        scheme: FlexScheme.indigo,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          cardRadius: 20.0,
          cardElevation: 0,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts.dmSans().fontFamily,
      );
}