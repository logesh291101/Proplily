import 'package:flutter/material.dart';

/// Centers content with a max width for tablet/desktop layouts.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = 520,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final contentWidth = width >= 600 ? maxWidth : width;
        final horizontal = ((width - contentWidth) / 2).clamp(0.0, 48.0);

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontal + padding.left,
            padding.top,
            horizontal + padding.right,
            padding.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
