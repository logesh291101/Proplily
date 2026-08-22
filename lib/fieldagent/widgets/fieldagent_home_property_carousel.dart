import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/utils/property_map_launcher.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedules_model.dart';
import 'package:proplilly/fieldagent/fieldagent_property_details_screen.dart';

/// Assigned properties carousel for the Field Agent home screen.
class FieldAgentHomePropertyCarousel extends StatefulWidget {
  const FieldAgentHomePropertyCarousel({
    super.key,
    required this.properties,
    this.isLoading = false,
  });

  final List<PropertyData> properties;
  final bool isLoading;

  @override
  State<FieldAgentHomePropertyCarousel> createState() =>
      _FieldAgentHomePropertyCarouselState();
}

class _FieldAgentHomePropertyCarouselState
    extends State<FieldAgentHomePropertyCarousel> {
  static const double _imageHeight = 160;

  late final PageController _pageController;
  int _currentIndex = 0;

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

  @override
  void didUpdateWidget(FieldAgentHomePropertyCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentIndex >= widget.properties.length &&
        widget.properties.isNotEmpty) {
      _currentIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  void _goToPrevious() {
    if (_currentIndex <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  void _goToNext(int count) {
    if (_currentIndex >= count - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openOnMap(PropertyData property) async {
    await PropertyMapLauncher.open(
      context,
      latitude: property.latitude ?? '',
      longitude: property.longitude ?? '',
    );
  }

  void _openDetails(PropertyData property) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FieldAgentPropertyDetailsScreen(property: property),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const _CarouselLoadingState();
    }

    if (widget.properties.isEmpty) {
      return const _CarouselEmptyState();
    }

    final properties = widget.properties;
    final property = properties[_currentIndex];
    final showPrevious = _currentIndex > 0;
    final showNext = _currentIndex < properties.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.06),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _imageHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: properties.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return _PropertyImageBanner(
                  property: properties[index],
                  showPrevious: showPrevious && properties.length > 1,
                  showNext: showNext && properties.length > 1,
                  onPrevious: _goToPrevious,
                  onNext: () => _goToNext(properties.length),
                );
              },
            ),
          ),
          _PropertyCarouselContent(
            property: property,
            onOpenOnMap: () => _openOnMap(property),
            onViewDetails: () => _openDetails(property),
          ),
        ],
      ),
    );
  }
}

class _PropertyImageBanner extends StatelessWidget {
  const _PropertyImageBanner({
    required this.property,
    required this.showPrevious,
    required this.showNext,
    required this.onPrevious,
    required this.onNext,
  });

  final PropertyData property;
  final bool showPrevious;
  final bool showNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final imageUrl = property.imageUrls.isNotEmpty
        ? property.imageUrls.first
        : property.propertyPhoto?.trim() ?? '';

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => const _PropertyImagePlaceholder(),
            errorWidget: (_, __, ___) => const _PropertyImagePlaceholder(),
          )
        else
          const _PropertyImagePlaceholder(),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.82),
              ],
            ),
          ),
        ),
        if (showPrevious)
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ImageNavArrow(
                icon: Icons.chevron_left_rounded,
                onPressed: onPrevious,
              ),
            ),
          ),
        if (showNext)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ImageNavArrow(
                icon: Icons.chevron_right_rounded,
                onPressed: onNext,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                property.propertyName?.trim().isNotEmpty == true
                    ? property.propertyName!.trim()
                    : '—',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                property.locationLine.isNotEmpty ? property.locationLine : '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.bodySmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PropertyCarouselContent extends StatelessWidget {
  const _PropertyCarouselContent({
    required this.property,
    required this.onOpenOnMap,
    required this.onViewDetails,
  });

  final PropertyData property;
  final VoidCallback onOpenOnMap;
  final VoidCallback onViewDetails;

  String get _statusDetail {
    final status = property.monitoringStatus?.trim();
    if (status == null || status.isEmpty) return '—';
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DetailColumn(
                  label: 'Status',
                  value: _statusDetail,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailColumn(
                  label: 'Account Manager',
                  value: property.accountManagerDisplay,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PremiumOutlineButton(
                  label: 'Open on Map',
                  onPressed:
                      property.hasMapCoordinates ? onOpenOnMap : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PremiumPrimaryButton(
                  label: 'View Details',
                  onPressed: onViewDetails,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageNavArrow extends StatelessWidget {
  const _ImageNavArrow({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.38),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            color: AppColors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _DetailColumn extends StatelessWidget {
  const _DetailColumn({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PropertyImagePlaceholder extends StatelessWidget {
  const _PropertyImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark.withValues(alpha: 0.85),
      child: Icon(
        Icons.home_work_outlined,
        size: 40,
        color: AppColors.white.withValues(alpha: 0.45),
      ),
    );
  }
}

class _CarouselLoadingState extends StatelessWidget {
  const _CarouselLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.2),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _CarouselEmptyState extends StatelessWidget {
  const _CarouselEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_work_outlined,
              size: 36,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No assigned properties available.',
            textAlign: TextAlign.center,
            style: theme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
