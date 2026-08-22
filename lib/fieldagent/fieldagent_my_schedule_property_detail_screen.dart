import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/utils/property_map_launcher.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_screen_scaffold.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedule_property_detail_service.dart';
import 'package:proplilly/fieldagent/my_schedule_property_detail_model.dart';
import 'package:url_launcher/url_launcher.dart';

class FieldAgentMySchedulePropertyDetailScreen extends StatefulWidget {
  const FieldAgentMySchedulePropertyDetailScreen({
    super.key,
    required this.taskId,
  });

  final String taskId;

  @override
  State<FieldAgentMySchedulePropertyDetailScreen> createState() =>
      _FieldAgentMySchedulePropertyDetailScreenState();
}

class _FieldAgentMySchedulePropertyDetailScreenState
    extends State<FieldAgentMySchedulePropertyDetailScreen> {
  final FieldAgentMySchedulePropertyDetailService _service =
      FieldAgentMySchedulePropertyDetailService();

  late final PageController _pageController;
  int _currentImageIndex = 0;

  bool _isLoading = true;
  String? _errorMessage;
  MySchedulePropertyDetail? _detail;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadDetail();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.fetchTaskDetail(widget.taskId);
    if (!mounted) return;

    switch (result) {
      case MySchedulePropertyDetailFetchSuccess(:final model):
        final detail = model.data;
        log(
          'Property Details lat/lng — '
          'taskId: ${widget.taskId}, '
          'propertyLat: ${detail.propertyLat}, '
          'propertyLng: ${detail.propertyLng}, '
          'hasMapCoordinates: ${detail.hasMapCoordinates}',
          name: 'OpenInMap',
        );
        setState(() {
          _detail = detail;
          _isLoading = false;
        });
      case MySchedulePropertyDetailFetchFailure(:final message):
        log(
          'Property Details fetch failed — taskId: ${widget.taskId}, message: $message',
          name: 'OpenInMap',
        );
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return FieldAgentScreenScaffold(
      title: 'Property Details',
      subtitle: 'View property information and location details.',
      icon: Icons.home_outlined,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return PremiumErrorState(
        message: _errorMessage!,
        onRetry: _loadDetail,
      );
    }

    final detail = _detail;
    if (detail == null) {
      return PremiumErrorState(
        message: 'Property details are not available.',
        onRetry: _loadDetail,
      );
    }

    final horizontal = ScreenSpacing.horizontal(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // _PropertyImageCarousel(
          //   images: detail.imageUrls,
          //   pageController: _pageController,
          //   currentIndex: _currentImageIndex,
          //   onPageChanged: (index) => setState(() => _currentImageIndex = index),
          // ),
          // const SizedBox(height: 18),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.propertyName.trim().isNotEmpty
                      ? detail.propertyName.trim()
                      : '—',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail.address.trim().isNotEmpty
                      ? detail.address.trim()
                      : '—',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail.city.trim().isNotEmpty ? detail.city.trim() : '—',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 10),
                _StatusChip(status: detail.status),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Property Information',
            child: Column(
              children: detail.scheduleInfoEntries
                  .map(
                    (entry) => _RecordRow(
                      label: entry.label,
                      value: entry.value,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Account Manager',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RecordRow(
                  label: 'Name',
                  value: detail.accountManagerName.trim().isNotEmpty
                      ? detail.accountManagerName.trim()
                      : '—',
                ),
                _RecordRow(
                  label: 'Phone Number',
                  value: detail.accountManagerPhone.trim().isNotEmpty
                      ? detail.accountManagerPhone.trim()
                      : '—',
                ),
                _RecordRow(
                  label: 'Email Address',
                  value: detail.accountManagerEmail.trim().isNotEmpty
                      ? detail.accountManagerEmail.trim()
                      : '—',
                ),
                const SizedBox(height: 8),
                PremiumPrimaryButton(
                  label: 'Call Account Manager',
                  icon: Icons.phone_outlined,
                  onPressed: detail.callUri != null
                      ? () => _launchUri(detail.callUri, 'phone')
                      : null,
                ),
                const SizedBox(height: 12),
                PremiumOutlineButton(
                  label: 'Email Account Manager',
                  onPressed: detail.emailUri != null
                      ? () => _launchUri(detail.emailUri, 'email')
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Location',
            child: PremiumOutlineButton(
              label: 'Open in Map',
              onPressed: () {
                log(
                  'Open in Map tapped — '
                  'taskId: ${widget.taskId}, '
                  'propertyLat: ${detail.propertyLat}, '
                  'propertyLng: ${detail.propertyLng}, '
                  'hasMapCoordinates: ${detail.hasMapCoordinates}',
                  name: 'OpenInMap',
                );
                PropertyMapLauncher.open(
                  context,
                  latitude: detail.propertyLat,
                  longitude: detail.propertyLng,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final label = status?.trim();
    if (label == null || label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1).toLowerCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
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
