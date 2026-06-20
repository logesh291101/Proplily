import 'package:flutter/material.dart';

/// Responsive spacing between app chrome (AppBar / header) and body content.
class ScreenSpacing {
  ScreenSpacing._();

  /// Gap directly below [AppBar] before scrollable content begins.
  static double belowAppBar(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return (height * 0.02).clamp(16.0, 24.0);
  }

  /// Gap between a gradient header block and the next section.
  static double belowHeader(BuildContext context) {
    return belowAppBar(context);
  }

  /// Subtle overlap for floating cards that sit on a header (kept small).
  static double floatingCardOverlap(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return (height * 0.012).clamp(8.0, 14.0);
  }

  /// Horizontal page padding for main content.
  static double horizontal(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width * 0.05).clamp(16.0, 24.0);
  }
}
