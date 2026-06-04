import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tappable phone or email row with circular icon background.
class ClientSupportTicketContactRow extends StatelessWidget {
  const ClientSupportTicketContactRow({
    super.key,
    required this.icon,
    required this.label,
    required this.uri,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final Uri uri;
  final Color iconColor;

  Future<void> _open(BuildContext context) async {
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $label')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: PremiumDecorations.iconTile(iconColor),
                child: Icon(icon, color: AppColors.primaryDark, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.primaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
