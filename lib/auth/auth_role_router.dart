import 'package:flutter/material.dart';
import 'package:proplilly/client/screens/client_home_page.dart';
import 'package:proplilly/fieldagent/screens/fieldagent_home_screen.dart';

/// Maps API `user.role` values to the correct post-login home screen.
abstract final class AuthRoleRouter {
  static const String client = 'client';
  static const String fieldAgent = 'field_agent';

  static String normalizeRole(String? raw) => raw?.trim().toLowerCase() ?? '';

  /// Returns the home widget for [role], or `null` if the role is not supported.
  static Widget? homeForRole(String role) {
    switch (normalizeRole(role)) {
      case client:
        return const HomePage();
      case fieldAgent:
        return const FieldAgentHomeScreen();
      default:
        return null;
    }
  }
}
