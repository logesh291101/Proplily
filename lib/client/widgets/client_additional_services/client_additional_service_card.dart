import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_additional_service_extensions.dart';
import 'package:proplilly/client/models/client_additional_service_model.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';

class ClientAdditionalServiceCard extends StatelessWidget {
  const ClientAdditionalServiceCard({
    super.key,
    required this.service,
  });

  final ClientAdditionalService service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final comments = service.displayComments;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.displayServiceType,
            style: theme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          if (comments != null) ...[
            const SizedBox(height: 8),
            Text(
              comments,
              style: theme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            service.formattedCreatedAt,
            style: theme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
