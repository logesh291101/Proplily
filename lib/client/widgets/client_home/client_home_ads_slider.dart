import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_ads_model.dart';
import 'package:proplilly/client/screens/client_ad_details_screen.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/widgets/client_ad_interest_dialog.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';

/// Auto-sliding ads banner for the Client home screen.
class ClientHomeAdsSlider extends StatefulWidget {
  const ClientHomeAdsSlider({
    super.key,
    required this.ads,
  });

  final List<ClientAdData> ads;

  @override
  State<ClientHomeAdsSlider> createState() => _ClientHomeAdsSliderState();
}

class _ClientHomeAdsSliderState extends State<ClientHomeAdsSlider> {
  static const Duration _autoSlideInterval = Duration(seconds: 4);

  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(ClientHomeAdsSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ads.length != widget.ads.length) {
      _currentIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    if (widget.ads.length <= 1) return;

    _autoSlideTimer = Timer.periodic(_autoSlideInterval, (_) {
      if (!mounted || widget.ads.length <= 1) return;

      final nextIndex = (_currentIndex + 1) % widget.ads.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _startAutoSlide();
  }

  void _openAdDetails(ClientAdData ad) {
    final adId = ad.id?.trim();
    if (adId == null || adId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad ID is not available.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ClientAdDetailsScreen(
          adId: adId,
          ad: ad,
        ),
      ),
    );
  }

  void _openInterestDialog(ClientAdData ad) {
    showClientAdInterestDialog(context, ad: ad);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentAd = widget.ads[_currentIndex];
    final ctaLabel = currentAd.ctaText?.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.ads.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return _AdBannerSlide(
                ad: widget.ads[index],
                onViewFullAd: () => _openAdDetails(widget.ads[index]),
              );
            },
          ),
        ),
        if (widget.ads.length > 1) ...[
          const SizedBox(height: 10),
          _PageIndicator(
            count: widget.ads.length,
            currentIndex: _currentIndex,
          ),
        ],
        if (ctaLabel != null && ctaLabel.isNotEmpty) ...[
          const SizedBox(height: 12),
          PremiumPrimaryButton(
            label: ctaLabel,
            onPressed: () => _openInterestDialog(currentAd),
          ),
        ],
      ],
    );
  }
}

class _AdBannerSlide extends StatelessWidget {
  const _AdBannerSlide({
    required this.ad,
    required this.onViewFullAd,
  });

  final ClientAdData ad;
  final VoidCallback onViewFullAd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final imageUrl = ad.bannerImageUrl;
    final title = ad.title?.trim();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const _AdImagePlaceholder(),
              errorWidget: (_, __, ___) => const _AdImagePlaceholder(),
            )
          else
            const _AdImagePlaceholder(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: onViewFullAd,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: Colors.black.withValues(alpha: 0.35),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      'View Full Ad',
                      style: theme.labelLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                if (title != null && title.isNotEmpty)
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
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
