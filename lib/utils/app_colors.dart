import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors - warm, appetizing meat-themed palette
  static const Color primary = Color(0xFF105D6D); // Rich red for meat theme
  static const Color primaryLight = Color(0xFF5DA8AD); // Lighter red
  static const Color primaryDark = Color(0xFF156660); // Darker red
  
  // Secondary colors
  static const Color secondary = Color(0xFFF39C12); // Warm orange
  static const Color accent = Color(0xFF27AE60); // Fresh green for vegetables/herbs
  
  // Background colors
  static const Color background = Color(0xFFFFFCF5);
  static const Color surface = Color(0xFFFFFCF5);
  static const Color surfaceVariant = Color(0xFFFFFCF5);
  
  // Text colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);
  
  // Status colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
  
  // Border and divider
  static const Color border = Color(0xFFE5E5E5);
  static const Color divider = Color(0xFFECF0F1);
  
  // Special colors
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  
  // Gradient combinations
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFFFFCF5), Color(0xFFFFFCF5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}