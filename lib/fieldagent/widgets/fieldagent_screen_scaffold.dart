import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/ui/proplilly_screen_hero_section.dart';

/// Field Agent screen shell: AppBar + gradient hero + scrollable/flexible body.
class FieldAgentScreenScaffold extends StatelessWidget {
  const FieldAgentScreenScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.body,
    this.appBar,
    this.header,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBar ?? ProplillyAppBar.heroOverlay(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header ??
              ProplillyScreenHeroSection(
                title: title,
                subtitle: subtitle,
                icon: icon,
              ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
