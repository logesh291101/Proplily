import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/utils/property_map_launcher.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_screen_scaffold.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedule_screen.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedules_model.dart';
import 'package:url_launcher/url_launcher.dart';

class FieldAgentPropertyDetailsScreen extends StatefulWidget {
  const FieldAgentPropertyDetailsScreen({
    super.key,
    required this.property,
  });

  final PropertyData property;

  @override
  State<FieldAgentPropertyDetailsScreen> createState() =>
      _FieldAgentPropertyDetailsScreenState();
}

class _FieldAgentPropertyDetailsScreenState
    extends State<FieldAgentPropertyDetailsScreen> {
  late final PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  PropertyData get property => widget.property;

  Future<void> _launchUri(Uri? uri, String label) async {
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label is not available.')),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $label.')),
      );
    }
  }

  void _openSchedules() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const FieldAgentMyScheduleScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);
    final images = property.imageUrls;

    return FieldAgentScreenScaffold(
      title: 'Property Details',
      subtitle: 'View property information and location details.',
      icon: Icons.home_outlined,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PropertyImageCarousel(
              images: images,
              pageController: _pageController,
              currentIndex: _currentImageIndex,
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.propertyName?.trim().isNotEmpty == true
                        ? property.propertyName!.trim()
                        : '—',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.locationLine.isNotEmpty
                        ? property.locationLine
                        : '—',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Quick Actions',
              child: PremiumPrimaryButton(
                label: 'My Schedule & Reports',
                icon: Icons.calendar_month_outlined,
                onPressed: _openSchedules,
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Property Location',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (property.hasMapCoordinates) ...[
                    _RecordRow(
                      label: 'Latitude',
                      value: property.latitude!.trim(),
                    ),
                    _RecordRow(
                      label: 'Longitude',
                      value: property.longitude!.trim(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  PremiumOutlineButton(
                    label: 'Open on Map',
                    onPressed: property.hasMapCoordinates
                        ? () => PropertyMapLauncher.open(
                              context,
                              latitude: property.latitude ?? '',
                              longitude: property.longitude ?? '',
                            )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Account Manager (Point of Contact)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.accountManagerDisplay,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Contact the account manager for any questions about the client or listing.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Field agents do not receive client name, phone, or email.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 16),
                  PremiumPrimaryButton(
                    label: 'Call Account Manager',
                    icon: Icons.phone_outlined,
                    onPressed: property.callUri != null
                        ? () => _launchUri(property.callUri, 'phone')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  PremiumOutlineButton(
                    label: 'Email Account Manager',
                    onPressed: property.emailUri != null
                        ? () => _launchUri(property.emailUri, 'email')
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Property Record',
              child: Column(
                children: property.recordEntries
                    .map(
                      (entry) => _RecordRow(
                        label: entry.label,
                        value: entry.value,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyImageCarousel extends StatelessWidget {
  const _PropertyImageCarousel({
    required this.images,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> images;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: images.isEmpty
                ? _ImagePlaceholder()
                : PageView.builder(
                    controller: pageController,
                    itemCount: images.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                        errorWidget: (_, __, ___) => _ImagePlaceholder(),
                      );
                    },
                  ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isActive = index == currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 10 : 8,
                height: isActive ? 10 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primaryLight.withValues(alpha: 0.5),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accent.withValues(alpha: 0.35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: AppColors.primaryDark.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 8),
          Text(
            'No image available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    this.title,
    required this.child,
  });

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: PremiumDecorations.cardShadow(),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
