import 'package:flutter/material.dart';

class AppColors {
  // --- CORE APPLE PAY NOIR PALETTE ---
  static const background = Color(0xFF000000);
  static const cardBg = Color(0xFF1C1C1E); 
  static const primary = Color(0xFF0A84FF); // Apple Blue
  static const success = Color(0xFF32D74B); // Apple Green
  static const danger = Color(0xFFFF453A);  // Apple Red
  static const warning = Color(0xFFFF9F0A); // Apple Orange
  static const lifeColor = Color(0xFFBF5AF2); // Apple Purple
  static const gold = Color(0xFFF5D1B0);    // Champagne Gold
  static const info = Color(0xFF5AC8FA);    // Apple Light Blue

  // --- TYPOGRAPHY ---
  static const textMain = Color(0xFFFFFFFF);
  static const textDim = Color(0xFF8E8E93);

  // --- ALIASES (This is what stops the red line errors) ---
  static const darkBackground = background;
  static const darkSurface = cardBg;
  static const surface = cardBg;
  static const textPrimary = textMain;
  static const textSecondary = textDim;
  
  static final Color white05 = Colors.white.withOpacity(0.05);
  static final Color white10 = Colors.white.withOpacity(0.1);
  static final Color glass = Colors.white.withOpacity(0.05);
  static final Color glassBorder = Colors.white.withOpacity(0.08);

  static const grad = LinearGradient(
    colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const primaryGradient = grad;
}