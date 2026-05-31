// UX Constants
import 'dart:ui';

class UXConstants {
  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Gesture thresholds
  static const double swipeThreshold = 100.0;
  static const double tapTimeout = 300.0;

  // Loading states
  static const Duration loadingTimeout = Duration(seconds: 30);
  static const Duration refreshTimeout = Duration(seconds: 10);
}

// UI Constants
class UIConstants {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Button heights
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;

  // Screen breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}

// Color Constants
class ColorConstants {
  // Primary
  static const Color primary = Color(0xFF184A6C);
  static const Color primaryVariant = Color(0xFF4C8592);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary
  static const Color secondary = Color(0xFF889E5B);
  static const Color secondaryVariant = Color(0xFF9AB2A8);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Background
  static const Color background = Color(0xFFF7F9F8);
  static const Color onBackground = Color(0xFF184A6C);
  static const Color surface = Color(0xFFD2E0D7);
  static const Color onSurface = Color(0xFF184A6C);

  // Status
  static const Color error = Color(0xFFB00020);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF889E5B);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF4C8592);

  // Neutral
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Brand palette
  static const Color primaryGreen = Color(0xFF889E5B);
  static const Color softGreen = Color(0xFFD2E0D7);
  static const Color primaryBlue = Color(0xFF184A6C);
  static const Color mediumBlue = Color(0xFF4C8592);
  static const Color mutedGreen = Color(0xFF9AB2A8);

  // Opacity
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.60;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1.0;
}
