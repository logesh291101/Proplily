import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_report_extensions.dart';
import 'package:proplilly/client/models/client_report_model.dart';
import 'package:proplilly/client/services/client_visit_report_details_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/ui/modern_info_row.dart';
import 'package:proplilly/client/widgets/ui/modern_section_card.dart';

/// Visit report details from `GET {live_url}/user/visit-reports/{report_id}`.
class ClientVisitReportDetailsScreen extends StatefulWidget {
  const ClientVisitReportDetailsScreen({
    super.key,
    required this.reportId,
  });

  final String reportId;

  @override
  State<ClientVisitReportDetailsScreen> createState() =>
      _ClientVisitReportDetailsScreenState();
}

class _ClientVisitReportDetailsScreenState
    extends State<ClientVisitReportDetailsScreen> {
  final _service = ClientVisitReportDetailsService();

  bool _isLoading = true;
  String? _errorMessage;
  ClientReportData? _report;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.fetchReportDetails(
      reportId: widget.reportId,
    );
    if (!mounted) return;

    switch (result) {
      case ClientVisitReportDetailFetchSuccess(:final model):
        setState(() {
          _isLoading = false;
          _report = model.data;
          _errorMessage = null;
        });
      case ClientVisitReportDetailFetchFailure(:final message):
        setState(() {
          _isLoading = false;
          _report = null;
          _errorMessage = message;
        });
    }
  }

  void _openImageViewer(int initialIndex) {
    final images = _report?.imageUrls ?? [];
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

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Visit Report'),
        actions: ProplillyAppBar.clientActions(),
      ),
      body: RefreshIndicator(
        onRefresh: _loadReport,
        color: AppColors.primary,
        child: _buildBody(context, horizontal),
      ),
    );
  }

  Widget _buildBody(BuildContext context, double horizontal) {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
        children: [
          Text(
            'Loading report...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24),
          ...List.generate(3, (_) => const _ReportDetailSkeleton()),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.55,
            child: PremiumErrorState(
              message: _errorMessage!,
              onRetry: _loadReport,
            ),
          ),
        ],
      );
    }

    final report = _report;
    if (report == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
        children: const [
          Center(child: Text('No reports found.')),
        ],
      );
    }

    final images = report.imageUrls;
    final theme = Theme.of(context).textTheme;
    final reportId = report.reportId?.trim().isNotEmpty == true
        ? report.reportId!.trim()
        : widget.reportId;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent.withValues(alpha: 0.5),
                AppColors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
            boxShadow: PremiumDecorations.cardShadow(opacity: 0.06),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Field Visit Report #$reportId',
                style: theme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                report.displayPropertyName,
                style: theme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: report.reviewStatusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: report.reviewStatusColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  report.reviewStatusLabel,
                  style: theme.labelLarge?.copyWith(
                    color: report.reviewStatusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ModernSectionCard(
          title: 'Visit Details',
          titleIcon: Icons.event_note_outlined,
          child: Column(
            children: [
              ModernInfoRow(
                icon: Icons.category_outlined,
                label: 'Visit Type',
                value: report.displayVisitType,
                showDivider: false,
              ),
              const SizedBox(height: 12),
              ModernInfoRow(
                icon: Icons.info_outline_rounded,
                label: 'Visit Status',
                value: report.visitStatus?.trim().isNotEmpty == true
                    ? report.visitStatus!.trim()
                    : '—',
                showDivider: false,
              ),
              const SizedBox(height: 12),
              ModernInfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Visit Date',
                value: formatClientReportDate(report.visitDate),
                showDivider: false,
              ),
            ],
          ),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 18),
          ModernSectionCard(
            title: 'Property Images',
            titleIcon: Icons.photo_library_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _openImageViewer(index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                PremiumOutlineButton(
                  label: 'View Full',
                  onPressed: () => _openImageViewer(0),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        ModernSectionCard(
          title: 'Agent Remarks',
          titleIcon: Icons.chat_bubble_outline_rounded,
          child: Text(
            report.agentRemarks,
            style: theme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportDetailSkeleton extends StatelessWidget {
  const _ReportDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 120,
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
        actions: ProplillyAppBar.clientActions(),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (index) => setState(() => _index = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.contain,
                placeholder: (_, __) => const CircularProgressIndicator(
                  color: AppColors.white,
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.white,
                  size: 48,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
