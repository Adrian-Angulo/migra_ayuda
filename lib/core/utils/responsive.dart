import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';


extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isMobile => screenWidth < UIConstants.mobileBreakpoint;
  bool get isTablet =>
      screenWidth >= UIConstants.mobileBreakpoint &&
      screenWidth < UIConstants.tabletBreakpoint;

  bool get isDesktop => screenWidth >= UIConstants.tabletBreakpoint;

  bool get isCompact => screenWidth < UIConstants.tabletBreakpoint;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < UIConstants.mobileBreakpoint) {
          return mobile;
        } else if (constraints.maxWidth < UIConstants.tabletBreakpoint) {
          return tablet ?? mobile;
        } else {
          return desktop;
        }
      },
    );
  }
}
