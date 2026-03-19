import 'package:flutter/material.dart';

class Responsive {
  static double screenWidth(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double screenHeight(BuildContext context) => MediaQuery.sizeOf(context).height;

  /// Scales horizontal/vertical spacing based on screen width
  /// Base design width: 390 (iPhone 12/13/14)
  static double sp(double size, BuildContext context) {
    double width = screenWidth(context);
    // On tablets, we don't want spacing to grow linearly too much
    if (width > 600) {
      return size * (600 / 390);
    }
    return size * (width / 390);
  }

  /// Scales font size
  static double fs(double size, BuildContext context) {
    double width = screenWidth(context);
    if (width > 600) {
      return size * 1.25; // Moderate growth for tablets
    }
    return size * (width / 390);
  }

  static bool isTablet(BuildContext context) => screenWidth(context) >= 600;
  static bool isSmallPhone(BuildContext context) => screenWidth(context) < 360;

  /// Returns a scaled value for Nimbus Mascot
  /// Base size (70x56) is now for Tablets (600+)
  /// Scales down for smaller screens by percentage
  static double mascotSize(BuildContext context, {required double base}) {
    double width = screenWidth(context);
    double scale = (width / 600).clamp(0.65, 1.0);
    return base * scale;
  }
}
