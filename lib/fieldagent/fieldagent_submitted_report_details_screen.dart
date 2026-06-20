import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/fieldagent/fieldagent_submit_report_screen.dart';
import 'package:proplilly/fieldagent/fieldagent_submitted_report_extensions.dart';
import 'package:proplilly/fieldagent/fieldagent_submitted_report_model.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_screen_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class FieldAgentSubmittedReportDetailsScreen extends StatelessWidget {
  const FieldAgentSubmittedReportDetailsScreen({
    super.key,
    required this.reportId,
    required this.report,
  });

  final String reportId;
  final FieldAgentSubmittedReportData report;

  Future<void> _openVideo(BuildContext context, String? url) async {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open video.')),
      );
    }
  }

  void _openImageViewer(BuildContext context, int initialIndex) {
    final images = report.imageUrls;
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

  void _editAndResubmit(BuildContext context) {
    final taskId = report.taskId?.trim();
    if (taskId == null || taskId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task ID is not available for resubmission.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FieldAgentSubmitReportScreen(taskId: taskId),
      ),
    );
  }

  String _display(String? value) {
    final trimmed = value?.trim();
    return (trimmed != null && trimmed.isNotEmpty) ? trimmed : '—';
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);
    final theme = Theme.of(context).textTheme;
    final images = report.imageUrls;

    return FieldAgentScreenScaffold(
      title: 'Report Details',
      subtitle: 'Review submitted report details and status.',
      icon: Icons.article_outlined,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              title: 'Report Information',
              child: Column(
                children: [
                  _RecordRow(
                    label: 'Report ID',
                    value: report.displayReportId,
                  ),
                  _RecordRow(
                    label: 'Submitted Date',
                    value: formatSubmittedReportDate(report.submittedAt),
                  ),
                  // _RecordRow(
                  //   label: 'Created At',
                  //   value: formatSubmittedReportDate(report.createdAt),
                  // ),
                  // _RecordRow(
                  //   label: 'Updated At',
                  //   value: formatSubmittedReportDate(report.updatedAt),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Property Details',
              child: Column(
                children: [
                  _RecordRow(
                    label: 'Property Name',
                    value: report.displayPropertyName,
                  ),
                  // _RecordRow(
                  //   label: 'Property Location',
                  //   value: report.displayLocation,
                  // ),
                  if (report.propertyId?.trim().isNotEmpty == true)
                    _RecordRow(
                      label: 'Property ID',
                      value: report.propertyId!.trim(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Visit Details',
              child: Column(
                children: [
                  _RecordRow(
                    label: 'Visit Type',
                    value: report.displayVisitType,
                  ),
                  _RecordRow(
                    label: 'Visit Status',
                    value: _display(report.visitStatus),
                  ),
                  _RecordRow(
                    label: 'Visit Date',
                    value: formatSubmittedReportDate(report.visitDate),
                  ),
                  // if (report.taskId?.trim().isNotEmpty == true)
                  //   _RecordRow(
                  //     label: 'Task ID',
                  //     value: report.taskId!.trim(),
                  //   ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Review Status',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: report.reviewStatusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: report.reviewStatusColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      report.reviewStatusLabel,
                      style: theme.titleSmall?.copyWith(
                        color: report.reviewStatusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Agent Remarks',
              child: Text(
                report.agentRemarks,
                style: theme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ),
            if (images.isNotEmpty) ...[
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Property Images',
                child: GridView.builder(
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
                      onTap: () => _openImageViewer(context, index),
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
              ),
            ],
            if (report.videoFile?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Uploaded Video',
                child: PremiumOutlineButton(
                  label: 'Play Video',
                  onPressed: () => _openVideo(context, report.videoFile),
                ),
              ),
            ],
            if (report.managerComments?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Manager Remarks',
                child: Text(
                  report.managerRemarks,
                  style: theme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ),
            ],
            // if (report.hasApprovalInfo) ...[
            //   const SizedBox(height: 14),
            //   _SectionCard(
            //     title: 'Approval/Rejection Information',
            //     child: Column(
            //       children: [
            //         if (report.managerDecision?.trim().isNotEmpty == true)
            //           _RecordRow(
            //             label: 'Manager Decision',
            //             value: report.managerDecision!.trim(),
            //           ),
            //         if (report.managerReviewedBy?.trim().isNotEmpty == true)
            //           _RecordRow(
            //             label: 'Reviewed By',
            //             value: report.managerReviewedBy!.trim(),
            //           ),
            //         if (report.managerReviewedAt?.trim().isNotEmpty == true)
            //           _RecordRow(
            //             label: 'Reviewed At',
            //             value: formatSubmittedReportDate(
            //               report.managerReviewedAt,
            //             ),
            //           ),
            //         if (report.adminFinalStatus?.trim().isNotEmpty == true)
            //           _RecordRow(
            //             label: 'Admin Final Status',
            //             value: report.adminFinalStatus!.trim(),
            //           ),
            //         if (report.adminOverrideNotes?.trim().isNotEmpty == true)
            //           _RecordRow(
            //             label: 'Admin Override Notes',
            //             value: report.adminOverrideNotes!.trim(),
            //           ),
            //         if (report.adminReviewedBy?.trim().isNotEmpty == true)
            //           _RecordRow(
            //             label: 'Admin Reviewed By',
            //             value: report.adminReviewedBy!.trim(),
            //           ),
            //         if (report.adminReviewedAt?.trim().isNotEmpty == true)
            //           _RecordRow(
            //             label: 'Admin Reviewed At',
            //             value: formatSubmittedReportDate(
            //               report.adminReviewedAt,
            //             ),
            //           ),
            //       ],
            //     ),
            //   ),
            // ],
            if (report.isRejected) ...[
              const SizedBox(height: 20),
              PremiumPrimaryButton(
                label: 'Edit & Resubmit',
                icon: Icons.edit_outlined,
                onPressed: () => _editAndResubmit(context),
              ),
            ],
          ],
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
        actions: ProplillyAppBar.logoActions(),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
          ),
          const SizedBox(height: 14),
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
