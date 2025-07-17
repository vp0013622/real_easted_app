import 'package:flutter/material.dart';

class ColorUtils {
  /// Calculate the luminance of a color (0.0 to 1.0)
  static double _getLuminance(Color color) {
    return color.computeLuminance();
  }

  /// Check if a color is considered "light" (luminance > 0.5)
  static bool isLightColor(Color color) {
    return _getLuminance(color) > 0.5;
  }

  /// Get appropriate text color for a background color
  static Color getTextColorForBackground(Color backgroundColor) {
    return isLightColor(backgroundColor) ? Colors.black87 : Colors.white;
  }

  /// Get appropriate icon color for a background color
  static Color getIconColorForBackground(Color backgroundColor) {
    return isLightColor(backgroundColor) ? Colors.black87 : Colors.white;
  }

  /// Get a contrasting color for UI elements
  static Color getContrastingColor(Color backgroundColor) {
    return isLightColor(backgroundColor) ? Colors.black87 : Colors.white;
  }

  /// Ensure AppBar has proper contrast
  static AppBarTheme getAppBarTheme(Color primaryColor, bool isDark) {
    final isLightPrimary = isLightColor(primaryColor);

    return AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: isLightPrimary ? Colors.black87 : Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(
        color: isLightPrimary ? Colors.black87 : Colors.white,
      ),
      titleTextStyle: TextStyle(
        color: isLightPrimary ? Colors.black87 : Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  /// Get safe background color for cards
  static Color getSafeCardBackground(bool isDark) {
    return isDark ? const Color(0xFF2D2D2D) : Colors.white;
  }

  /// Get safe text color
  static Color getSafeTextColor(bool isDark) {
    return isDark ? Colors.white : Colors.black87;
  }

  /// Get safe icon color
  static Color getSafeIconColor(bool isDark) {
    return isDark ? Colors.white : Colors.black87;
  }

  /// Ensure button has proper contrast
  static ButtonStyle getSafeButtonStyle(Color primaryColor, bool isDark) {
    final isLightPrimary = isLightColor(primaryColor);

    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: isLightPrimary ? Colors.black87 : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
