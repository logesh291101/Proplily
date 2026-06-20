import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';

/// Gradient welcome banner below the home [AppBar].
class HomeWelcomeHeader extends StatelessWidget {
  const HomeWelcomeHeader({
    super.key,
    required this.firstName,
  });

  final String firstName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final height = MediaQuery.sizeOf(context).height * 0.14;

    return Container(
      width: double.infinity,
      height: height,
      margin: EdgeInsets.only(bottom: ScreenSpacing.belowHeader(context)),
      decoration: const BoxDecoration(
        gradient: PremiumDecorations.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -16,
            child: Icon(
              Icons.blur_on,
              size: 140,
              color: AppColors.white.withValues(alpha: 0.07),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.bold)
                ),
                const SizedBox(height: 6),
                Text(
                  '$firstName',
                  style: theme.headlineSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
