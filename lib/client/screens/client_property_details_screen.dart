import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_properties_model.dart';
import 'package:proplilly/client/models/client_property_extensions.dart';
import 'package:proplilly/client/screens/client_update_property_screen.dart';
import 'package:proplilly/client/services/client_my_properties_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:url_launcher/url_launcher.dart';

/// Property details for a [ClientPropertyData] from the My Properties list.
class ClientPropertyDetailsScreen extends StatefulWidget {
  ClientPropertyDetailsScreen({
    super.key,
    ClientPropertyData? propertyData,
    ClientPropertyData? property,
  }) : propertyData = propertyData ?? property! {
    assert(
      propertyData != null || property != null,
      'Either propertyData or property must be provided.',
    );
  }

  final ClientPropertyData propertyData;

  @override
  State<ClientPropertyDetailsScreen> createState() =>
      _ClientPropertyDetailsScreenState();
}

class _ClientPropertyDetailsScreenState
    extends State<ClientPropertyDetailsScreen> {
  late final PageController _imageController;
  final _propertiesService = ClientMyPropertiesService();

  late ClientPropertyData _propertyData;
  bool _wasUpdated = false;
  int _currentImageIndex = 0;

  ClientPropertyData get propertyData => _propertyData;
  Property get property => _propertyData.property;

  @override
  void initState() {
    super.initState();
    _propertyData = widget.propertyData;
    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  void _goToPreviousImage(int imageCount) {
    if (_currentImageIndex <= 0 || imageCount <= 1) return;
    _imageController.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextImage(int imageCount) {
    if (_currentImageIndex >= imageCount - 1 || imageCount <= 1) return;
    _imageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  void _openImageViewer(int initialIndex) {
    final images = propertyData.imageUrls;
    if (images.isEmpty) return;

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullScreenImageViewer(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  bool _isImageDocument(String url) {
    final lower = url.trim().toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  Future<void> _openDocument(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    if (_isImageDocument(trimmed)) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => _FullScreenImageViewer(
            images: [trimmed],
            initialIndex: 0,
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open document.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _reloadProperty() async {
    final propertyId = property.propertyId.trim();
    if (propertyId.isEmpty) return;

    final result = await _propertiesService.fetchProperties();
    if (!mounted) return;

    if (result case ClientPropertiesFetchSuccess(:final properties)) {
      ClientPropertyData? updated;
      for (final item in properties) {
        if (item.property.propertyId.trim() == propertyId) {
          updated = item;
          break;
        }
      }

      if (updated != null) {
        setState(() {
          _propertyData = updated!;
          _currentImageIndex = 0;
        });
        if (_imageController.hasClients) {
          _imageController.jumpToPage(0);
        }
      }
    }
  }

  Future<void> _openEditProperty() async {
    final propertyId = property.propertyId.trim();
    if (propertyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property ID is not available.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ClientUpdatePropertyScreen(
          propertyId: propertyId,
          propertyData: _propertyData,
        ),
      ),
    );

    if (updated == true && mounted) {
      _wasUpdated = true;
      await _reloadProperty();
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);
    final images = propertyData.imageUrls;
    final documents = propertyData.documentUrls;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_wasUpdated);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Property Details'),
          actions: ProplillyAppBar.clientActions(),
        ),
        body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PropertyImageCarousel(
                    images: images,
                    pageController: _imageController,
                    currentIndex: _currentImageIndex,
                    onPageChanged: (index) =>
                        setState(() => _currentImageIndex = index),
                    onImageTap: _openImageViewer,
                    onPrevious: () => _goToPreviousImage(images.length),
                    onNext: () => _goToNextImage(images.length),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PropertyInfoGrid(propertyData: propertyData),
                        if (documents.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Documents',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (var i = 0; i < documents.length; i++)
                                SizedBox(
                                  width: documents.length == 1
                                      ? double.infinity
                                      : null,
                                  child: PremiumOutlineButton(
                                    label: documents.length == 1
                                        ? 'View Document'
                                        : 'View Document ${i + 1}',
                                    onPressed: () => _openDocument(documents[i]),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
            child: PremiumPrimaryButton(
              label: 'Edit Details',
              icon: Icons.edit_outlined,
              onPressed: _openEditProperty,
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
    required this.onImageTap,
    required this.onPrevious,
    required this.onNext,
  });

  final List<String> images;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onImageTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final carouselHeight = screenWidth * 0.62;
    final showArrows = images.length > 1;

    return SizedBox(
      height: carouselHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.isEmpty)
            const _ImagePlaceholder()
          else
            PageView.builder(
              controller: pageController,
              itemCount: images.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onImageTap(index),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (_, __) => Container(
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => const _ImagePlaceholder(),
                  ),
                );
              },
            ),
          if (showArrows) ...[
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CarouselArrowButton(
                  icon: Icons.chevron_left_rounded,
                  enabled: currentIndex > 0,
                  onTap: onPrevious,
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CarouselArrowButton(
                  icon: Icons.chevron_right_rounded,
                  enabled: currentIndex < images.length - 1,
                  onTap: onNext,
                ),
              ),
            ),
          ],
          if (images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: Row(
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
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.45),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _CarouselArrowButton extends StatelessWidget {
  const _CarouselArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: enabled ? 0.38 : 0.18),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: AppColors.white.withValues(alpha: enabled ? 1 : 0.45),
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _PropertyInfoGrid extends StatelessWidget {
  const _PropertyInfoGrid({required this.propertyData});

  final ClientPropertyData propertyData;

  @override
  Widget build(BuildContext context) {
    final property = propertyData.property;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PropertyInfoCard(
          label: 'Property Name',
          value: propertyData.displayValue(property.propertyName),
          icon: Icons.home_work_outlined,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PropertyInfoCard(
                label: 'Property Type',
                value: propertyData.displayValue(property.propertyType),
                icon: Icons.category_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PropertyInfoCard(
                label: 'Status',
                value: propertyData.displayStatus,
                icon: Icons.info_outline_rounded,
                valueColor: _statusColor(propertyData.displayStatus),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PropertyInfoCard(
                label: 'City',
                value: propertyData.displayValue(property.city),
                icon: Icons.location_city_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PropertyInfoCard(
                label: 'State',
                value: propertyData.displayValue(property.state),
                icon: Icons.map_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _PropertyInfoCard(
          label: 'Address',
          value: propertyData.displayValue(property.address),
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PropertyInfoCard(
                label: 'Plot Type',
                value: propertyData.displayPlotType,
                icon: Icons.landscape_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PropertyInfoCard(
                label: 'Plot Size',
                value: propertyData.displayArea,
                icon: Icons.square_foot_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color? _statusColor(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized.contains('active') || normalized.contains('approved')) {
      return AppColors.success;
    }
    if (normalized.contains('pending') || normalized.contains('review')) {
      return AppColors.warning;
    }
    if (normalized.contains('reject') || normalized.contains('inactive')) {
      return AppColors.error;
    }
    return null;
  }
}

class _PropertyInfoCard extends StatelessWidget {
  const _PropertyInfoCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: PremiumDecorations.iconTile(AppColors.primary),
                child: Icon(icon, size: 16, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.titleSmall?.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark.withValues(alpha: 0.85),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 56,
            color: AppColors.white.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 10),
          Text(
            'No image available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        title: Text('${_index + 1} / ${widget.images.length}'),
        actions: ProplillyAppBar.clientActions(includeNotification: false),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (index) => setState(() => _index = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
