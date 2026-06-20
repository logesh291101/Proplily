import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';

/// Wraps scaffold body content with consistent spacing below an [AppBar].
class PremiumScreenBody extends StatelessWidget {
  const PremiumScreenBody({
    super.key,
    required this.child,
    this.applyTopSpacing = true,
    this.padding,
  });

  final Widget child;
  final bool applyTopSpacing;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final top = applyTopSpacing ? ScreenSpacing.belowAppBar(context) : 0.0;
    final resolvedPadding = padding ??
        EdgeInsets.fromLTRB(
          ScreenSpacing.horizontal(context),
          top,
          ScreenSpacing.horizontal(context),
          0,
        );

    return SafeArea(
      child: Padding(
        padding: resolvedPadding,
        child: child,
      ),
    );
  }
}
