import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_screen_scaffold.dart';

/// Simple scaffold wrapper for Field Agent feature screens.
class FieldAgentModuleScreen extends StatelessWidget {
  const FieldAgentModuleScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.message,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final horizontal = ScreenSpacing.horizontal(context);

    return FieldAgentScreenScaffold(
      title: title,
      subtitle: subtitle,
      icon: icon,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.28),
              ),
              boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
