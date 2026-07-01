import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/models/client_market_headlines_extensions.dart';
import 'package:proplilly/client/models/client_market_lines_model.dart';
import 'package:proplilly/client/providers/client_home_market_headlines_provider.dart';
import 'package:proplilly/client/screens/client_market_headline_details_screen.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/widgets/client_home/client_home_section_title.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';

/// Market headlines list for the Client home screen.
class ClientHomeMarketHeadlinesSection extends StatelessWidget {
  const ClientHomeMarketHeadlinesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientHomeMarketHeadlinesProvider>(
      builder: (context, provider, _) {
        if (!provider.shouldShowSection) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const HomeSectionTitle(
              title: 'Market Headlines',
              subtitle:
                  'Stay updated with the latest real estate market news.',
              icon: Icons.newspaper_outlined,
            ),
            if (provider.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Loading market headlines...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              )
            else if (provider.errorMessage != null)
              _MarketHeadlinesError(
                message: provider.errorMessage!,
                onRetry: provider.refresh,
              )
            else
              _MarketHeadlinesHorizontalList(headlines: provider.headlines),
          ],
        );
      },
    );
  }
}

class _MarketHeadlinesHorizontalList extends StatelessWidget {
  const _MarketHeadlinesHorizontalList({required this.headlines});

  final List<ClientMarketHeadline> headlines;

  static const double _cardSpacing = 12;

  @override
  Widget build(BuildContext context) {
    if (headlines.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    const parentHorizontalPadding = 20.0;
    final availableWidth = screenWidth - (parentHorizontalPadding * 2);
    final cardWidth = availableWidth * 0.82;
    final imageHeight = cardWidth * 9 / 16;
    const textBlockHeight = 132.0;
    final listHeight = imageHeight + textBlockHeight;

    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: headlines.length,
        separatorBuilder: (_, __) => const SizedBox(width: _cardSpacing),
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            height: listHeight,
            child: _MarketHeadlineCard(headline: headlines[index]),
          );
        },
      ),
    );
  }
}

class _MarketHeadlinesError extends StatelessWidget {
  const _MarketHeadlinesError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: theme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: PremiumOutlineButton(
              label: 'Try again',
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketHeadlineCard extends StatelessWidget {
  const _MarketHeadlineCard({required this.headline});

  final ClientMarketHeadline headline;

  void _openDetails(BuildContext context) {
    final headlineId = headline.id.trim();
    if (headlineId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Headline ID is not available.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ClientMarketHeadlineDetailsScreen(
          headlineId: headlineId,
          headline: headline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final imageUrl = headline.cardImageUrl;
    final location = headline.category.trim();
    final title = headline.title.trim();
    final metaLine = headline.sourceWithTime;

    return Material(
      color: AppColors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetails(context),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            const _HeadlineImagePlaceholder(),
                        errorWidget: (_, __, ___) =>
                            const _HeadlineImagePlaceholder(),
                      )
                    : const _HeadlineImagePlaceholder(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (location.isNotEmpty)
                        Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.labelLarge?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      if (title.isNotEmpty) ...[
                        if (location.isNotEmpty) const SizedBox(height: 6),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (metaLine.isNotEmpty)
                        Text(
                          metaLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
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
