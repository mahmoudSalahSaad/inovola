import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double getHorizontalPadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return 12.0;
    } else if (isMediumScreen(context)) {
      return 20.0;
    } else {
      return 32.0;
    }
  }

  static double getVerticalPadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return 12.0;
    } else if (isMediumScreen(context)) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  static double getCardPadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return 12.0;
    } else if (isMediumScreen(context)) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  static double getSpacing(BuildContext context) {
    if (isSmallScreen(context)) {
      return 12.0;
    } else if (isMediumScreen(context)) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  static double getHeaderFontSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 24.0;
    } else if (isMediumScreen(context)) {
      return 28.0;
    } else {
      return 32.0;
    }
  }

  static double getIconSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 18.0;
    } else if (isMediumScreen(context)) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  static double getAvatarRadius(BuildContext context) {
    if (isSmallScreen(context)) {
      return 18.0;
    } else if (isMediumScreen(context)) {
      return 20.0;
    } else {
      return 24.0;
    }
  }
}
