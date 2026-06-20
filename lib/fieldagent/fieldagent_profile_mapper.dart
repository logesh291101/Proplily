import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proplilly/client/models/client_home_dashboard.dart';
import 'package:proplilly/client/models/client_user_profile.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/fieldagent/fieldagent_profile_model.dart';

/// Maps [FieldAgentProfileModel] API data to [UserProfile] for shared profile widgets.
abstract final class FieldAgentProfileMapper {
  static final DateFormat _displayDate = DateFormat('MMM dd, yyyy');

  static UserProfile? toUserProfile(FieldAgentProfileModel model) {
    final data = model.data;
    if (data == null) return null;

    return UserProfile(
      name: data.name?.trim() ?? '',
      email: data.email?.trim() ?? '',
      phoneNumber: _formatPhone(data),
      subscriptionPlan: data.role?.trim() ?? '',
      subscriptionStatus: _parseSubscriptionStatus(data.status),
      memberSince: _formatDate(data.createdAt),
      renewalDate: _renewalLabel(data),
      activities: _buildActivities(data),
    );
  }

  static bool isDeletionScheduled(FieldAgentProfileData data) {
    final scheduledAt = data.deleteScheduledAt?.trim();
    if (scheduledAt != null && scheduledAt.isNotEmpty) return true;

    final deleted = data.deletedAt?.trim();
    if (deleted != null && deleted.isNotEmpty) return true;

    return false;
  }

  static String _formatPhone(FieldAgentProfileData data) {
    final phone = data.phone?.trim() ?? '';
    final code = data.countryCode?.trim() ?? '';
    if (phone.isEmpty) return code;
    if (code.isEmpty) return phone;
    return '$code $phone';
  }

  static SubscriptionStatus _parseSubscriptionStatus(String? raw) {
    final normalized = raw?.trim().toLowerCase() ?? '';
    if (normalized == '1' ||
        normalized == 'active' ||
        normalized == 'true') {
      return SubscriptionStatus.active;
    }
    if (normalized == '0' ||
        normalized == 'inactive' ||
        normalized == 'expired' ||
        normalized == 'false') {
      return SubscriptionStatus.expired;
    }
    return SubscriptionStatus.active;
  }

  static String _formatDate(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    try {
      return _displayDate.format(DateTime.parse(trimmed));
    } catch (_) {
      return trimmed;
    }
  }

  static String _renewalLabel(FieldAgentProfileData data) {
    final expires = data.tokenExpiresAt?.trim();
    if (expires != null && expires.isNotEmpty) {
      return _formatDate(expires);
    }
    final lastLogin = data.lastLogin?.trim() ?? '';
    if (lastLogin.isNotEmpty) {
      return _formatDate(lastLogin);
    }
    return '';
  }

  static List<ActivityItem> _buildActivities(FieldAgentProfileData data) {
    final items = <ActivityItem>[];

    final lastLogin = data.lastLogin?.trim() ?? '';
    if (lastLogin.isNotEmpty) {
      items.add(
        ActivityItem(
          dateLabel: _formatDate(lastLogin),
          title: 'Last Login',
          description: data.lastIp?.trim().isNotEmpty == true
              ? 'Signed in from ${data.lastIp!.trim()}'
              : 'Last sign-in recorded for your account.',
          icon: Icons.login_rounded,
          accentColor: AppColors.primary,
        ),
      );
    }

    final referredAt = data.referredAt?.trim();
    if (referredAt != null && referredAt.isNotEmpty) {
      items.add(
        ActivityItem(
          dateLabel: _formatDate(referredAt),
          title: 'Referral',
          description: data.ownReferralCode?.trim().isNotEmpty == true
              ? 'Referral code: ${data.ownReferralCode!.trim()}'
              : 'Referral activity on your account.',
          icon: Icons.card_giftcard_outlined,
          accentColor: AppColors.success,
        ),
      );
    }

    final updatedAt = data.updatedAt?.trim();
    if (updatedAt != null && updatedAt.isNotEmpty) {
      items.add(
        ActivityItem(
          dateLabel: _formatDate(updatedAt),
          title: 'Profile Updated',
          description: 'Your profile details were last updated.',
          icon: Icons.person_outline_rounded,
          accentColor: const Color(0xFF5C6BC0),
        ),
      );
    }

    return items;
  }
}
