import 'package:flutter/material.dart';

class ResponsiveLayout {
  static const EdgeInsets _mobilePadding = EdgeInsets.all(16.0);
  static const EdgeInsets _tabletPadding = EdgeInsets.all(24.0);
  static const EdgeInsets _desktopPadding = EdgeInsets.all(32.0);

  static bool isMobileLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 600;
  }

  static bool isTabletLayout(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktopLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 1200;
  }

  static double getSpacing(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return 16.0;
    if (width < 1200) return 20.0;
    return 24.0;
  }

  static EdgeInsets getPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return _mobilePadding;
    if (width < 1200) return _tabletPadding;
    return _desktopPadding;
  }

  static double getFontSize(BuildContext context, {required double base}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return base;
    if (width < 1200) return base * 1.1;
    return base * 1.2;
  }

  static double getButtonHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 600 ? 52.0 : 56.0;
  }

  static double getIconSize(BuildContext context, {required double base}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return base;
    if (width < 1200) return base * 1.15;
    return base * 1.3;
  }

  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return width;
    if (width < 1200) return 600;
    return 800;
  }
}
