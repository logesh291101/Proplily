import 'package:flutter/material.dart';
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Welcome hero banner for the Field Agent home screen.
class FieldAgentHomeHeroSection extends StatefulWidget {
  const FieldAgentHomeHeroSection({
    super.key,
    this.heightFactor = 0.16,
  });

  final double heightFactor;

  @override
  State<FieldAgentHomeHeroSection> createState() =>
      _FieldAgentHomeHeroSectionState();
}

class _FieldAgentHomeHeroSectionState extends State<FieldAgentHomeHeroSection> {
  String _name = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(AuthPreferenceKeys.name)?.trim() ?? '';
    final role = prefs.getString(AuthPreferenceKeys.role)?.trim() ?? '';

    if (!mounted) return;
    setState(() {
      _name = name;
      _role = role;
    });
  }

  static String formatRole(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed
        .split(RegExp(r'[\s_]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) => part.length == 1
              ? part.toUpperCase()
              : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final height = MediaQuery.sizeOf(context).height * widget.heightFactor;
    final formattedRole = formatRole(_role);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: PremiumDecorations.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.16),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -36,
            top: -24,
            child: Icon(
              Icons.blur_on,
              size: 150,
              color: AppColors.white.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            left: -30,
            bottom: 30,
            child: Icon(
              Icons.blur_on,
              size: 100,
              color: AppColors.white.withValues(alpha: 0.05),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    'Welcome Back,',
                    style: theme.labelLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                        fontSize:22
                    ),
                  ),
                  if (_name.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _name,
                      style: theme.headlineSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize:17
                      ),
                    ),
                  ],
                  if (formattedRole.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      formattedRole,
                      style: theme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
