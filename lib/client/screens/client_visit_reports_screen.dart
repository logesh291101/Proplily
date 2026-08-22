import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_report_extensions.dart';
import 'package:proplilly/client/models/client_report_model.dart';
import 'package:proplilly/client/screens/client_visit_report_details_screen.dart';
import 'package:proplilly/client/services/client_visit_reports_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/ui/proplilly_screen_hero_section.dart';

/// Lists visit reports from `GET {live_url}/user/visit-reports`.
class ClientVisitReportsScreen extends StatefulWidget {
  const ClientVisitReportsScreen({super.key});

  @override
  State<ClientVisitReportsScreen> createState() =>
      _ClientVisitReportsScreenState();
}

class _ClientVisitReportsScreenState extends State<ClientVisitReportsScreen> {
  final _service = ClientVisitReportsService();

  bool _isLoading = true;
  String? _errorMessage;
  List<ClientReportData> _loadedReports = <ClientReportData>[];

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

    final result = await _service.fetchVisitReports();
    if (!mounted) return;

    switch (result) {
      case ClientVisitReportsFetchSuccess(:final model):
        setState(() {
          _isLoading = false;
          _loadedReports = List<ClientReportData>.from(model.data ?? const []);
          _errorMessage = null;
        });
      case ClientVisitReportsFetchFailure(:final message):
        setState(() {
          _isLoading = false;
          _loadedReports = <ClientReportData>[];
          _errorMessage = message;
        });
    }
  }

  void _openReportDetails(ClientReportData report) {
    final reportId = report.reportId?.trim();
    if (reportId == null || reportId.isEmpty) return;

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ClientVisitReportDetailsScreen(reportId: reportId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        //title: const Text('Visit Reports'),
        actions: ProplillyAppBar.clientActions(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProplillyScreenHeroSection(
            title: 'Visit Reports',
            subtitle:
                'View all submitted and approved reports for your properties.',
            icon: Icons.assignment_outlined,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadReports,
              color: AppColors.primary,
              child: _buildBody(context, horizontal),
            ),
          ),
        ],
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
            'Loading reports...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (_) => const _VisitReportCardSkeleton()),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.45,
            child: PremiumErrorState(
              message: _errorMessage!,
              onRetry: _loadReports,
            ),
          ),
        ],
      );
    }

    if (_loadedReports.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
        children: const [
          SizedBox(height: 32),
          _VisitReportsEmptyState(),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
      itemCount: _loadedReports.length,
      itemBuilder: (context, index) {
        final report = _loadedReports[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _VisitReportCard(
            report: report,
            onViewReport: () => _openReportDetails(report),
          ),
        );
      },
    );
  }
}

class _VisitReportCard extends StatelessWidget {
  const _VisitReportCard({
    required this.report,
    required this.onViewReport,
  });

  final ClientReportData report;
  final VoidCallback onViewReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            report.formattedReportDate,
            style: theme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            report.displayPropertyName,
            style: theme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          _ReportMetaRow(
            label: 'Location',
            value: report.displayLocation,
          ),
          const SizedBox(height: 4),
          _ReportMetaRow(
            label: 'Visit Type',
            value: report.displayVisitType,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          ),
          const SizedBox(height: 16),
          PremiumOutlineButton(
            label: 'View Report',
            onPressed: onViewReport,
          ),
        ],
      ),
    );
  }
}

class _ReportMetaRow extends StatelessWidget {
  const _ReportMetaRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        style: theme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _VisitReportsEmptyState extends StatelessWidget {
  const _VisitReportsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.assignment_outlined,
          size: 56,
          color: AppColors.primaryLight.withValues(alpha: 0.8),
        ),
        const SizedBox(height: 14),
        Text(
          'No reports found.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _VisitReportCardSkeleton extends StatelessWidget {
  const _VisitReportCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 180,
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
