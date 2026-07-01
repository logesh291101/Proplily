import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_market_headlines_extensions.dart';
import 'package:proplilly/client/models/client_market_lines_model.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';

class ClientMarketHeadlineDetailsScreen extends StatefulWidget {
  const ClientMarketHeadlineDetailsScreen({
    super.key,
    required this.headlineId,
    required this.headline,
  });

  final String headlineId;
  final ClientMarketHeadline headline;

  @override
  State<ClientMarketHeadlineDetailsScreen> createState() =>
      _ClientMarketHeadlineDetailsScreenState();
}

class _ClientMarketHeadlineDetailsScreenState
    extends State<ClientMarketHeadlineDetailsScreen> {
  late final PageController _imageController;
  int _currentImageIndex = 0;

  ClientMarketHeadline get headline => widget.headline;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  void _goToPreviousImage() {
    if (_currentImageIndex <= 0) return;
    _imageController.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextImage(int imageCount) {
    if (_currentImageIndex >= imageCount - 1) return;
    _imageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);
    final theme = Theme.of(context).textTheme;
    final images = headline.detailImageUrls;
    final title = headline.title.trim();
    final location = headline.category.trim();
    final source = headline.authorName.trim();
    final publishedDate = headline.formattedPublishedDate;
    final content = headline.displayContent;

    final sourceLine = _buildSourceLine(source, publishedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProplillyAppBar.clientHeroOverlay(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeadlineImageCarousel(
              images: images,
              pageController: _imageController,
              currentIndex: _currentImageIndex,
              onPageChanged: (index) =>
                  setState(() => _currentImageIndex = index),
              onPrevious: _goToPreviousImage,
              onNext: () => _goToNextImage(images.length),
            ),
            const SizedBox(height: 20),
            if (title.isNotEmpty)
              Text(
                title,
                style: theme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                  height: 1.2,
                ),
              ),
            if (location.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                location,
                style: theme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (sourceLine.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                sourceLine,
                style: theme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Divider(
              height: 1,
              color: Color(0xFFE8D8EE),
            ),
            const SizedBox(height: 20),
            if (content.isNotEmpty)
              Text(
                content,
                style: theme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _buildSourceLine(String source, String publishedDate) {
    final hasSource = source.isNotEmpty;
    final hasDate = publishedDate.isNotEmpty && publishedDate != '—';

    if (!hasSource && !hasDate) return '';
    if (!hasSource) return publishedDate;
    if (!hasDate) return source;
    return '$source • $publishedDate';
  }
}

class _HeadlineImageCarousel extends StatelessWidget {
  const _HeadlineImageCarousel({
    required this.images,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onPrevious,
    required this.onNext,
  });

  final List<String> images;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final hasMultiple = images.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: images.isEmpty
                ? const _HeadlineImagePlaceholder()
                : hasMultiple
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          PageView.builder(
                            controller: pageController,
                            itemCount: images.length,
                            onPageChanged: onPageChanged,
                            itemBuilder: (context, index) {
                              return _HeadlineNetworkImage(
                                imageUrl: images[index],
                              );
                            },
                          ),
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
                      )
                    : _HeadlineNetworkImage(imageUrl: images.first),
          ),
        ),
        if (hasMultiple) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isActive = index == currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 10 : 8,
                height: isActive ? 10 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primaryLight.withValues(alpha: 0.45),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _HeadlineNetworkImage extends StatelessWidget {
  const _HeadlineNetworkImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => const _HeadlineImagePlaceholder(),
      errorWidget: (_, __, ___) => const _HeadlineImagePlaceholder(),
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

class _HeadlineImagePlaceholder extends StatelessWidget {
  const _HeadlineImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark.withValues(alpha: 0.85),
      child: Icon(
        Icons.newspaper_outlined,
        size: 48,
        color: AppColors.white.withValues(alpha: 0.45),
      ),
    );
  }
}
