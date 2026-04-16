import 'package:flutter/material.dart';

class AppColors {
  // Primary Action Color
  static const Color primary = Color.fromARGB(255, 234, 86, 84);
  
  // Backgrounds
  static const Color background = Color(0xFFF3F3F5);
  static const Color white = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textHint = Color(0xFF9CA3AF);
  
  // Borders
  static const Color border = Color(0xFFE5E7EB);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  // Premium Dark Mode Palette (Slate)
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);    // Slate 800
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkBorder = Color(0xFF334155);     // Slate 700

  // Context-aware color getters for Dark Mode support
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getBackgroundColor(BuildContext context) => isDarkMode(context) ? darkBackground : background;
  static Color getSurfaceColor(BuildContext context) => isDarkMode(context) ? darkSurface : white;
  static Color getTextPrimaryColor(BuildContext context) => isDarkMode(context) ? darkTextPrimary : textPrimary;
  static Color getTextSecondaryColor(BuildContext context) => isDarkMode(context) ? darkTextSecondary : textSecondary;
  static Color getBorderColor(BuildContext context) => isDarkMode(context) ? darkBorder : border;
}
