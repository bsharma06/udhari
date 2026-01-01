import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App-wide constants
class AppConstants {
  static const String appName = 'Udhaari';
  static const String appVersion = '1.0.0';

  // Database constants
  static const String dbName = 'udhari.db';
  static const int dbVersion = 2;

  // SMS processing constants
  static const int smsBatchSize = 100;
  static const String defaultCategory = 'General';

  // UI constants
  static const Duration snackBarDuration = Duration(seconds: 2);
  static const Duration errorSnackBarDuration = Duration(seconds: 3);
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 16.0;
}

/// Text theme utilities
TextTheme createTextTheme(
  BuildContext context,
  String bodyFontString,
  String displayFontString,
) {
  TextTheme baseTextTheme = Theme.of(context).textTheme;
  TextTheme bodyTextTheme = GoogleFonts.getTextTheme(
    bodyFontString,
    baseTextTheme,
  );
  TextTheme displayTextTheme = GoogleFonts.getTextTheme(
    displayFontString,
    baseTextTheme,
  );
  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}

/// Date formatting utilities
class DateUtils {
  static String formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return "Today";
    } else if (dateOnly == yesterday) {
      return "Yesterday";
    } else {
      return "${date.month}/${date.day}/${date.year}";
    }
  }

  static String formatDateTime(DateTime date) {
    return "${date.month}/${date.day}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}

/// Validation utilities
class ValidationUtils {
  static bool isValidPhoneNumber(String phone) {
    // Basic phone number validation
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    return phoneRegex.hasMatch(phone) && phone.length >= 7;
  }

  static bool isValidSmsBody(String body) {
    return body.isNotEmpty && body.trim().isNotEmpty;
  }
}

/// UI utilities
class UIUtils {
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: AppConstants.errorSnackBarDuration,
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: AppConstants.snackBarDuration),
    );
  }
}
