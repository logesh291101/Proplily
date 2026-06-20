import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_ads_model.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/client_ad_interest_dialog.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/ui/proplilly_screen_hero_section.dart';

class ClientAdDetailsScreen extends StatefulWidget {
  const ClientAdDetailsScreen({
    super.key,
    required this.adId,
    required this.ad,
  });

  final String adId;
  final ClientAdData ad;

  @override
  State<ClientAdDetailsScreen> createState() => _ClientAdDetailsScreenState();
}

class _ClientAdDetailsScreenState extends State<ClientAdDetailsScreen> {
  late final PageController _imageController;
  int _currentImageIndex = 0;

  ClientAdData get ad => widget.ad;

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

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);
    final theme = Theme.of(context).textTheme;
    final images = ad.adImages;
    final title = ad.title?.trim();
    final content = ad.content?.trim();
    final ctaLabel = ad.ctaText?.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProplillyAppBar.clientHeroOverlay(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProplillyScreenHeroSection(
            title: title?.isNotEmpty == true ? title! : 'Ad Details',
            subtitle: 'View full ad information.',
            icon: Icons.campaign_outlined,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AdImageCarousel(
                    images: images,
                    pageController: _imageController,
                    currentIndex: _currentImageIndex,
                    onPageChanged: (index) =>
                        setState(() => _currentImageIndex = index),
                  ),
                  const SizedBox(height: 20),
                  if (title != null && title.isNotEmpty)
                    Text(
                      title,
                      style: theme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        height: 1.2,
                      ),
                    ),
                  if (content != null && content.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      content,
                      style: theme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (ctaLabel != null && ctaLabel.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    PremiumPrimaryButton(
                      label: ctaLabel,
                      onPressed: () => showClientAdInterestDialog(
                        context,
                        ad: ad,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdImageCarousel extends StatelessWidget {
  const _AdImageCarousel({
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: images.isEmpty
                ? const _AdImagePlaceholder()
                : PageView.builder(
                    controller: pageController,
                    itemCount: images.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const _AdImagePlaceholder(),
                        errorWidget: (_, __, ___) =>
                            const _AdImagePlaceholder(),
                      );
                    },
                  ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isActive = index == currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primaryLight.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _AdImagePlaceholder extends StatelessWidget {
  const _AdImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark.withValues(alpha: 0.85),
      child: Icon(
        Icons.campaign_outlined,
        size: 48,
        color: AppColors.white.withValues(alpha: 0.45),
      ),
    );
  }
}
