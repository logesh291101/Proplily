import 'package:flutter/material.dart';

/// Global keys for navigation and messaging outside widget trees.
abstract final class AppNavigator {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}
