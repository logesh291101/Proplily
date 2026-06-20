import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';

/// Gradient hero block; use [showNavigation] when an [AppBar] handles title/back.
class PremiumHeader extends StatelessWidget {
  const PremiumHeader({
    super.key,
    this.title,
    this.subtitle,
    this.bottomContent,
    this.heightFactor = 0.28,
    this.showNavigation = true,
  });

  final String? title;
  final String? subtitle;
  final Widget? bottomContent;
  final double heightFactor;
  final bool showNavigation;

  double _resolveHeight(double screenHeight) {
    if (bottomContent != null) {
      return (screenHeight * (heightFactor + 0.10)).clamp(300.0, 400.0);
    }
    if (subtitle != null) {
      return (screenHeight * heightFactor).clamp(220.0, 300.0);
    }
    return (screenHeight * heightFactor).clamp(200.0, 260.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final headerHeight = _resolveHeight(screenHeight);

    final bottomGap = ScreenSpacing.belowHeader(context);

    return Container(
      width: double.infinity,
      height: headerHeight,
      margin: EdgeInsets.only(bottom: bottomGap),
      decoration: const BoxDecoration(
        gradient: PremiumDecorations.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Icon(
              Icons.blur_on,
              size: 160,
              color: AppColors.white.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            left: -40,
            bottom: 20,
            child: Icon(
              Icons.blur_on,
              size: 120,
              color: AppColors.white.withValues(alpha: 0.05),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                showNavigation ? 8 : 20,
                showNavigation ? 4 : 16,
                20,
                bottomContent != null ? 0 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showNavigation && title != null)
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: AppColors.white,
                          iconSize: 20,
                        ),
                        Expanded(
                          child: Text(
                            title!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                          ),
                        ),
                      ],
                    )
                  else if (title != null) ...[
                    Text(
                      title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (subtitle != null) ...[
                    SizedBox(height: showNavigation ? 4 : 0),
                    Padding(
                      padding: EdgeInsets.only(
                        left: showNavigation ? 16 : 0,
                        right: 8,
                      ),
                      child: Text(
                        subtitle!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.88),
                              height: 1.45,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (bottomContent != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: bottomContent!,
            ),
        ],
      ),
    );
  }
}
