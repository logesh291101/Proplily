import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_properties_model.dart';
import 'package:proplilly/client/models/client_property_extensions.dart';
import 'package:proplilly/client/providers/client_home_properties_provider.dart';
import 'package:proplilly/client/screens/client_visit_reports_screen.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Property carousel for the Client home screen.
class HomePropertyCarousel extends StatefulWidget {
  const HomePropertyCarousel({super.key});

  @override
  State<HomePropertyCarousel> createState() => _HomePropertyCarouselState();
}

class _HomePropertyCarouselState extends State<HomePropertyCarousel> {
  static const double _cardHeight = 360;

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

  void _openVisitReports() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const ClientVisitReportsScreen(),
      ),
    );
  }

  Future<void> _openOnMap(ClientProperty property) async {
    if (!property.hasMapCoordinates) return;

    final lat = property.latitude?.trim() ?? '';
    final lng = property.longitude?.trim() ?? '';
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open map.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientHomePropertiesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && !provider.hasData) {
          return const _CarouselLoadingState();
        }

        if (provider.errorMessage != null && !provider.hasData) {
          return PremiumErrorState(
            message: provider.errorMessage!,
            onRetry: provider.refresh,
          );
        }

        if (!provider.hasData) {
          return const _CarouselEmptyState();
        }

        final properties = provider.properties;
        final showPrevious = _currentIndex > 0;
        final showNext = _currentIndex < properties.length - 1;

        return SizedBox(
          height: _cardHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: properties.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return _PropertyCarouselCard(
                property: properties[index],
                showPrevious: showPrevious && properties.length > 1,
                showNext: showNext && properties.length > 1,
                onPrevious: _goToPrevious,
                onNext: () => _goToNext(properties.length),
                onViewLatestReport: _openVisitReports,
                onOpenOnMap: () => _openOnMap(properties[index]),
              );
            },
          ),
        );
      },
    );
  }
}

class _PropertyCarouselCard extends StatelessWidget {
  const _PropertyCarouselCard({
    required this.property,
    required this.showPrevious,
    required this.showNext,
    required this.onPrevious,
    required this.onNext,
    required this.onViewLatestReport,
    required this.onOpenOnMap,
  });

  final ClientProperty property;
  final bool showPrevious;
  final bool showNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onViewLatestReport;
  final VoidCallback onOpenOnMap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final imageUrl = property.photoUrl;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const _PropertyImagePlaceholder(),
                    errorWidget: (_, __, ___) =>
                        const _PropertyImagePlaceholder(),
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
                      Text(
                        property.displayStatus,
                        style: theme.labelLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property.verifiedDaysAgoLabel,
                        style: theme.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        (property.propertyName?.trim().isNotEmpty ?? false)
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
                        property.displayLocation,
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
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _DetailColumn(
                          label: 'Area',
                          value: property.displayArea,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailColumn(
                          label: 'Updated At',
                          value: property.formattedUpdatedAt,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  PremiumPrimaryButton(
                    label: 'View Latest Report',
                    onPressed: onViewLatestReport,
                  ),
                  const SizedBox(height: 8),
                  PremiumOutlineButton(
                    label: 'Open on Map',
                    onPressed: property.hasMapCoordinates ? onOpenOnMap : null,
                  ),
                ],
              ),
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Loading properties...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 360,
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
        ),
      ],
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
            'No properties available.',
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
