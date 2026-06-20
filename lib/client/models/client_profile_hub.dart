import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';

/// Account & security menu entry on [ClientProfileScreen].
class ProfileAccountOption {
  const ProfileAccountOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

/// Static defaults for profile screen sections.
class ProfileHubContent {
  ProfileHubContent._();

  static const List<ProfileAccountOption> accountOptions = [
    ProfileAccountOption(
      title: 'Security & Credentials',
      subtitle: 'Password, 2FA, and login activity',
      icon: Icons.shield_outlined,
      color: AppColors.primary,
    ),
    ProfileAccountOption(
      title: 'Property Documents',
      subtitle: 'Leases, deeds, and uploaded files',
      icon: Icons.folder_copy_outlined,
      color: Color(0xFF5C6BC0),
    ),
    ProfileAccountOption(
      title: 'Notification Preferences',
      subtitle: 'Email, push, and SMS alerts',
      icon: Icons.notifications_active_outlined,
      color: Color(0xFF00897B),
    ),
    ProfileAccountOption(
      title: 'Privacy Settings',
      subtitle: 'Data sharing and visibility controls',
      icon: Icons.privacy_tip_outlined,
      color: Color(0xFF6D4C41),
    ),
  ];
}
