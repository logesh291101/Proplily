import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_screen_scaffold.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedules_model.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedules_service.dart';
import 'package:proplilly/fieldagent/fieldagent_property_details_screen.dart';
import 'package:proplilly/fieldagent/fieldagent_submitted_reports_screen.dart';

class FieldAgentMyAssignedPropertiesScreen extends StatefulWidget {
  const FieldAgentMyAssignedPropertiesScreen({super.key});

  @override
  State<FieldAgentMyAssignedPropertiesScreen> createState() =>
      _FieldAgentMyAssignedPropertiesScreenState();
}

class _FieldAgentMyAssignedPropertiesScreenState
    extends State<FieldAgentMyAssignedPropertiesScreen> {
  final FieldAgentMySchedulesService _service = FieldAgentMySchedulesService();

  bool _isLoading = true;
  String? _errorMessage;
  List<PropertyData> _properties = const [];

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.fetchProperties();
    if (!mounted) return;

    switch (result) {
      case FieldAgentMySchedulesFetchSuccess(:final model):
        setState(() {
          _properties = model.data ?? const [];
          _isLoading = false;
        });
      case FieldAgentMySchedulesFetchFailure(:final message):
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
    }
  }

  void _openDetails(PropertyData property) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FieldAgentPropertyDetailsScreen(property: property),
      ),
    );
  }

  void _openReports() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const FieldAgentSubmittedReportsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FieldAgentScreenScaffold(
      title: 'My Assignments',
      subtitle: 'Manage and inspect your assigned property portfolio.',
      icon: Icons.home_work_outlined,
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
        onRetry: _loadProperties,
      );
    }

    if (_properties.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadProperties,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
            const _AssignedPropertiesEmptyState(),
          ],
        ),
      );
    }

    final horizontal = ScreenSpacing.horizontal(context);

    return RefreshIndicator(
      onRefresh: _loadProperties,
      color: AppColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          horizontal,
          ScreenSpacing.belowAppBar(context),
          horizontal,
          32,
        ),
        itemCount: _properties.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return _AssignedPropertyCard(
            property: _properties[index],
            onFullDetails: () => _openDetails(_properties[index]),
            onViewReport: _openReports,
          );
        },
      ),
    );
  }
}

class _AssignedPropertyCard extends StatelessWidget {
  const _AssignedPropertyCard({
    required this.property,
    required this.onFullDetails,
    required this.onViewReport,
  });

  final PropertyData property;
  final VoidCallback onFullDetails;
  final VoidCallback onViewReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final status = property.monitoringStatus?.trim();

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
          Row(
            children: [
              const Text('🏠', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status?.isNotEmpty == true ? status! : 'Property Status',
                  style: theme.labelLarge?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            property.propertyName?.trim().isNotEmpty == true
                ? property.propertyName!.trim()
                : '—',
            style: theme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            property.locationLine.isNotEmpty ? property.locationLine : '—',
            style: theme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Text(
            'Account Manager (Point of Contact)',
            style: theme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            property.accountManagerDisplay,
            style: theme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _ContactLine(
            icon: Icons.phone_outlined,
            value: property.accountManagerPhone,
          ),
          const SizedBox(height: 6),
          _ContactLine(
            icon: Icons.email_outlined,
            value: property.accountManagerEmail,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: PremiumOutlineButton(
                  label: 'Full Details',
                  onPressed: onFullDetails,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PremiumPrimaryButton(
                  label: 'View Report',
                  onPressed: onViewReport,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final display = value?.trim().isNotEmpty == true ? value!.trim() : '—';

    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            display,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _AssignedPropertiesEmptyState extends StatelessWidget {
  const _AssignedPropertiesEmptyState();

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
                Icons.home_work_outlined,
                size: 48,
                color: AppColors.primaryDark.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No assigned properties found.',
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
