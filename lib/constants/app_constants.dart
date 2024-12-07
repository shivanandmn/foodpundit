import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class AppSizes {
  // Padding and Margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 20.0;
  static const double paddingXXLarge = 24.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 48.0;
  static const double iconXLarge = 50.0;

  // Button Sizes
  static const double buttonHeight = 60.0;
  static const double buttonWidth = 60.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;
  static const double radiusCircular = 50.0;

  // Border Width
  static const double borderWidth = 3.0;

  // Font Sizes
  static const double fontSmall = 12.0;
  static const double fontMedium = 14.0;
  static const double fontLarge = 16.0;
  static const double fontXLarge = 20.0;
  static const double fontXXLarge = 24.0;

  // Card Properties
  static const double cardElevation = 2.0;

  // Opacity Values
  static const double opacityLight = 0.1;
  static const double opacityMedium = 0.5;
  static const double opacityHigh = 0.8;
}

class AppStrings {
  // Profile Page
  static const String profileTitle = 'Profile';
  static const String userName = 'John Doe';
  static const String userEmail = 'john.doe@example.com';
  static const String scanHistory = 'Scan History';
  static const String scanCount = '23 scans';
  static const String favorites = 'Favorites';
  static const String favoriteCount = '5 items';
  static const String notifications = 'Notifications';
  static const String notificationStatus = 'On';
  static const String settings = 'Settings';

  // History Page
  static const String historyTitle = 'History';
  static const String scanPrefix = 'Scan';
  static const String scannedOn = 'Scanned on';
  static const String navigateToDetails = 'Navigate to product details';

  // Camera Page
  static const String cameraTitle = 'Scan Product';
  static const String errorTakingPicture = 'Error taking picture:';
  static const String imagePath = 'Image path:';
  static const String errorInitializingCamera = 'Error initializing camera:';
  static const String toggleFlash = 'Toggle flash';
  static const String switchCamera = 'Switch camera';
}

class AppBorderRadius {
  static final BorderRadius small = BorderRadius.circular(AppSizes.radiusSmall);
  static final BorderRadius medium = BorderRadius.circular(AppSizes.radiusMedium);
  static final BorderRadius large = BorderRadius.circular(AppSizes.radiusLarge);
  static const BorderRadius circular = BorderRadius.all(Radius.circular(50));
}

class AppEdgeInsets {
  static const EdgeInsets allSmall = EdgeInsets.all(AppSizes.paddingSmall);
  static const EdgeInsets allMedium = EdgeInsets.all(AppSizes.paddingMedium);
  static const EdgeInsets allLarge = EdgeInsets.all(AppSizes.paddingLarge);
  static const EdgeInsets allXLarge = EdgeInsets.all(AppSizes.paddingXLarge);
  
  static const EdgeInsets bottomMedium = EdgeInsets.only(bottom: AppSizes.paddingMedium);
  static const EdgeInsets bottomLarge = EdgeInsets.only(bottom: AppSizes.paddingLarge);
}

class AppCameraConfig {
  static const ResolutionPreset defaultResolution = ResolutionPreset.high;
  static const bool enableAudio = false;
  static const int maxHistoryItems = 10;
}
