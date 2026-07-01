import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/fieldagent/fieldagent_submitted_report_details_screen.dart';
import 'package:proplilly/fieldagent/fieldagent_submitted_report_extensions.dart';
import 'package:proplilly/fieldagent/fieldagent_submitted_report_model.dart';
import 'package:proplilly/fieldagent/fieldagent_submitted_reports_service.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_screen_scaffold.dart';

class FieldAgentSubmittedReportsScreen extends StatefulWidget {
  const FieldAgentSubmittedReportsScreen({super.key});

  @override
  State<FieldAgentSubmittedReportsScreen> createState() =>
      _FieldAgentSubmittedReportsScreenState();
}

class _FieldAgentSubmittedReportsScreenState
    extends State<FieldAgentSubmittedReportsScreen> {
  final FieldAgentSubmittedReportsService _service =
      FieldAgentSubmittedReportsService();

  bool _isLoading = true;
  String? _errorMessage;
  List<FieldAgentSubmittedReportData> _allReports = const [];
  SubmittedReportFilter _selectedFilter =
      SubmittedReportFilter.awaitingApprovals;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.fetchReports();
    if (!mounted) return;

    switch (result) {
      case FieldAgentSubmittedReportsFetchSuccess(:final model):
        setState(() {
          _allReports = model.data ?? const [];
          _isLoading = false;
        });
      case FieldAgentSubmittedReportsFetchFailure(:final message):
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
    }
  }

  List<FieldAgentSubmittedReportData> get _filteredReports {
    final filtered =
        _allReports.where((r) => _selectedFilter.matches(r)).toList();
    filtered.sort(compareSubmittedReportsBySubmittedAtDesc);
    return filtered;
  }

  void _openDetails(FieldAgentSubmittedReportData report) {
    final reportId = report.reportId?.trim();
    if (reportId == null || reportId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report ID is not available.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FieldAgentSubmittedReportDetailsScreen(
          reportId: reportId,
          report: report,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);

    return FieldAgentScreenScaffold(
      title: 'Submitted Reports',
      subtitle: 'Track submitted reports and edit only when manager sends back.',
      icon: Icons.fact_check_outlined,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 8),
            child: _ReportFilterBar(
              selectedFilter: _selectedFilter,
              onFilterSelected: (filter) {
                setState(() => _selectedFilter = filter);
              },
            ),
          ),
          Expanded(child: _buildBody(context, horizontal)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, double horizontal) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Loading submitted reports...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return PremiumErrorState(
        message: _errorMessage!,
        onRetry: _loadReports,
      );
    }

    final reports = _filteredReports;

    if (reports.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadReports,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
            const _ReportsEmptyState(),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${reports.length} ${reports.length == 1 ? 'report' : 'reports'}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadReports,
            color: AppColors.primary,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 32),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _SubmittedReportCard(
                  report: reports[index],
                  onViewDetails: () => _openDetails(reports[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportFilterBar extends StatelessWidget {
  const _ReportFilterBar({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final SubmittedReportFilter selectedFilter;
  final ValueChanged<SubmittedReportFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: SubmittedReportFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = SubmittedReportFilter.values[index];
          final isSelected = filter == selectedFilter;

          return Material(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => onFilterSelected(filter),
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primaryLight.withValues(alpha: 0.35),
                  ),
                ),
                child: Center(
                  child: Text(
                    filter.label,
                    style: theme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.primaryDark,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SubmittedReportCard extends StatelessWidget {
  const _SubmittedReportCard({
    required this.report,
    required this.onViewDetails,
  });

  final FieldAgentSubmittedReportData report;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.displayPropertyName,
            style: theme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          // Text(
          //   report.displayLocation,
          //   style: theme.bodyMedium?.copyWith(
          //     color: AppColors.textSecondary,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
          // const SizedBox(height: 12),
          //_InfoLine(label: 'Report ID', value: report.displayReportId),
         // _InfoLine(label: 'Visit Type', value: report.displayVisitType),
         //  _InfoLine(
         //    label: 'Visit Date',
         //    value: formatSubmittedReportDate(report.visitDate),
         //  ),
          _InfoLine(
            label: 'Submitted Date',
            value: formatSubmittedReportDate(report.submittedAt),
          ),
          // _InfoLine(
          //   label: 'Created At',
          //   value: formatSubmittedReportDate(report.createdAt),
          // ),
          _InfoLine(
            label: 'Visit Status',
            value: formatSubmittedReportDate(report.visitStatus),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Status : ',
                style: theme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  report.reviewStatusLabel,
                  style: theme.bodyMedium?.copyWith(
                    color: report.reviewStatusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          PremiumPrimaryButton(
            label: 'View Full Report',
            onPressed: onViewDetails,
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: theme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(
              text: '$label : ',
              style: theme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _ReportsEmptyState extends StatelessWidget {
  const _ReportsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenSpacing.horizontal(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 48,
                color: AppColors.primaryDark.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No submitted reports found.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
