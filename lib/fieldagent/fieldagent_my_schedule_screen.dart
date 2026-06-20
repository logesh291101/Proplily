import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_screen_scaffold.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedule_property_detail_screen.dart';
import 'package:proplilly/fieldagent/fieldagent_schedule_model.dart';
import 'package:proplilly/fieldagent/fieldagent_schedule_service.dart';
import 'package:proplilly/fieldagent/fieldagent_submit_report_screen.dart';
import 'package:proplilly/fieldagent/fieldagent_task_action_service.dart';
import 'package:proplilly/fieldagent/fieldagent_view_report_screen.dart';

class FieldAgentMyScheduleScreen extends StatefulWidget {
  const FieldAgentMyScheduleScreen({super.key});

  @override
  State<FieldAgentMyScheduleScreen> createState() =>
      _FieldAgentMyScheduleScreenState();
}

class _FieldAgentMyScheduleScreenState extends State<FieldAgentMyScheduleScreen> {
  static const List<String> _filterLabels = [
    'Completed Tasks',
    'Active Tasks',
    'Pending for Approval',
  ];

  static const Map<String, String> _filterApiStatusByLabel = {
    'Completed Tasks': 'completed',
    'Active Tasks': 'confirmed',
    'Pending for Approval': 'assigned',
  };

  final FieldAgentScheduleService _service = FieldAgentScheduleService();
  final FieldAgentTaskActionService _taskActionService =
      FieldAgentTaskActionService();
  final TextEditingController _propertyFilterController =
      TextEditingController();
  final DateFormat _visitDateDisplayFormat = DateFormat('dd-MM-yyyy');

  bool _isLoading = true;
  String? _errorMessage;
  List<FieldAgentSchedule> _allSchedules = const [];
  String _selectedFilterLabel = 'Active Tasks';
  DateTime? _selectedVisitDate;
  String? _processingTaskId;
  String? _processingAction;

  @override
  void initState() {
    super.initState();
    _propertyFilterController.addListener(_onSecondaryFiltersChanged);
    _loadSchedules();
  }

  @override
  void dispose() {
    _propertyFilterController.removeListener(_onSecondaryFiltersChanged);
    _propertyFilterController.dispose();
    super.dispose();
  }

  void _onSecondaryFiltersChanged() {
    setState(() {});
  }

  Future<void> _loadSchedules({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await _service.fetchSchedules();
    if (!mounted) return;

    switch (result) {
      case FieldAgentScheduleFetchSuccess(:final model):
        setState(() {
          _allSchedules = model.schedules;
          _isLoading = false;
        });
      case FieldAgentScheduleFetchFailure(:final message):
        setState(() {
          if (!silent) {
            _errorMessage = message;
          }
          _isLoading = false;
        });
    }
  }

  List<FieldAgentSchedule> get _filteredSchedules {
    final apiStatus = _filterApiStatusByLabel[_selectedFilterLabel] ?? '';
    var filtered = _allSchedules
        .where((s) => s.normalizedStatus == apiStatus)
        .toList();

    final propertyQuery = _propertyFilterController.text.trim();
    if (propertyQuery.isNotEmpty) {
      final query = propertyQuery.toLowerCase();
      filtered = filtered
          .where(
            (s) =>
                (s.propertyName?.trim().toLowerCase() ?? '').contains(query),
          )
          .toList();
    }

    if (_selectedVisitDate != null) {
      final target = DateTime(
        _selectedVisitDate!.year,
        _selectedVisitDate!.month,
        _selectedVisitDate!.day,
      );
      filtered = filtered.where((s) {
        final parsed = s.parsedScheduledDate;
        if (parsed == null) return false;
        final scheduleDate = DateTime(parsed.year, parsed.month, parsed.day);
        return scheduleDate == target;
      }).toList();
    }

    filtered.sort(FieldAgentSchedule.compareByScheduledDate);
    return filtered;
  }

  void _onFilterSelected(String filterLabel) {
    if (_selectedFilterLabel == filterLabel) return;
    setState(() => _selectedFilterLabel = filterLabel);
  }

  void _clearSecondaryFilters() {
    setState(() {
      _propertyFilterController.clear();
      _selectedVisitDate = null;
    });
  }

  Future<void> _pickVisitDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedVisitDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() => _selectedVisitDate = picked);
    }
  }

  String? _taskIdOrNotify(FieldAgentSchedule schedule) {
    final taskId = schedule.taskId?.trim();
    if (taskId == null || taskId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task ID is not available for this schedule.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return null;
    }
    return taskId;
  }

  void _openPropertyDetail(FieldAgentSchedule schedule) {
    final taskId = _taskIdOrNotify(schedule);
    if (taskId == null) return;

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FieldAgentMySchedulePropertyDetailScreen(
          taskId: taskId,
        ),
      ),
    );
  }

  void _openReport(FieldAgentSchedule schedule) {
    final taskId = _taskIdOrNotify(schedule);
    if (taskId == null) return;

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FieldAgentSubmitReportScreen(taskId: taskId),
      ),
    );
  }

  void _openViewReport(FieldAgentSchedule schedule) {
    final taskId = _taskIdOrNotify(schedule);
    if (taskId == null) return;

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FieldAgentViewReportScreen(taskId: taskId),
      ),
    );
  }

  Future<void> _acceptTask(FieldAgentSchedule schedule) async {
    final taskId = _taskIdOrNotify(schedule);
    if (taskId == null) return;

    setState(() {
      _processingTaskId = taskId;
      _processingAction = 'accept';
    });

    final result = await _taskActionService.acceptTask(taskId);
    if (!mounted) return;

    setState(() {
      _processingTaskId = null;
      _processingAction = null;
    });

    switch (result) {
      case FieldAgentTaskActionSuccess():
        await Fluttertoast.showToast(msg: 'Task accepted successfully.');
        await _loadSchedules(silent: true);
      case FieldAgentTaskActionFailure(:final message):
        await Fluttertoast.showToast(msg: message);
    }
  }

  Future<void> _showRejectDialog(FieldAgentSchedule schedule) async {
    final taskId = _taskIdOrNotify(schedule);
    if (taskId == null) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _RejectTaskDialog(
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSubmit: (reason) async {
            setState(() {
              _processingTaskId = taskId;
              _processingAction = 'reject';
            });

            final result = await _taskActionService.rejectTask(
              taskId: taskId,
              reason: reason,
            );

            if (!mounted) return;

            setState(() {
              _processingTaskId = null;
              _processingAction = null;
            });

            switch (result) {
              case FieldAgentTaskActionSuccess():
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                await Fluttertoast.showToast(
                  msg: 'Task rejected successfully.',
                );
                await _loadSchedules(silent: true);
              case FieldAgentTaskActionFailure(:final message):
                await Fluttertoast.showToast(msg: message);
            }
          },
        );
      },
    );
  }

  Future<void> _showRescheduleDialog(FieldAgentSchedule schedule) async {
    final taskId = _taskIdOrNotify(schedule);
    if (taskId == null) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _RescheduleTaskDialog(
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSubmit: (newDate, reason) async {
            setState(() {
              _processingTaskId = taskId;
              _processingAction = 'reschedule';
            });

            final result = await _taskActionService.rescheduleTask(
              taskId: taskId,
              newDate: newDate,
              reason: reason,
            );

            if (!mounted) return;

            setState(() {
              _processingTaskId = null;
              _processingAction = null;
            });

            switch (result) {
              case FieldAgentTaskActionSuccess():
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                await Fluttertoast.showToast(
                  msg: 'Reschedule request submitted successfully.',
                );
                await _loadSchedules(silent: true);
              case FieldAgentTaskActionFailure(:final message):
                await Fluttertoast.showToast(msg: message);
            }
          },
        );
      },
    );
  }

  bool _isProcessing(String taskId) => _processingTaskId == taskId;

  @override
  Widget build(BuildContext context) {
    return FieldAgentScreenScaffold(
      title: 'My Schedule',
      subtitle: 'All assigned tasks with visit planning and actions.',
      icon: Icons.calendar_month_outlined,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              ScreenSpacing.horizontal(context),
              16,
              ScreenSpacing.horizontal(context),
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ScheduleFilterBar(
                  filters: _filterLabels,
                  selectedFilter: _selectedFilterLabel,
                  onFilterSelected: _onFilterSelected,
                ),
                const SizedBox(height: 14),
                _ScheduleSecondaryFilterBar(
                  propertyController: _propertyFilterController,
                  visitDateLabel: _selectedVisitDate == null
                      ? null
                      : _visitDateDisplayFormat.format(_selectedVisitDate!),
                  onVisitDateTap: _pickVisitDate,
                  onClearFilters: _clearSecondaryFilters,
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(context)),
        ],
      ),
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
        onRetry: _loadSchedules,
      );
    }

    final schedules = _filteredSchedules;

    if (schedules.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadSchedules,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
            const _ScheduleEmptyState(),
          ],
        ),
      );
    }

    final horizontal = ScreenSpacing.horizontal(context);

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      color: AppColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(horizontal, 4, horizontal, 32),
        itemCount: schedules.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          final taskId = schedule.taskId?.trim() ?? '';
          final isProcessing = taskId.isNotEmpty && _isProcessing(taskId);
          final actionsEnabled = schedule.actionButtonsEnabled;

          return _ScheduleCard(
            schedule: schedule,
            isProcessing: isProcessing,
            processingAction: _processingAction,
            onProperty: isProcessing
                ? null
                : () => _openPropertyDetail(schedule),
            onReport: isProcessing ? null : () => _openReport(schedule),
            onViewReport: isProcessing
                ? null
                : () => _openViewReport(schedule),
            onAccept: isProcessing || !actionsEnabled
                ? null
                : () => _acceptTask(schedule),
            onReject: isProcessing || !actionsEnabled
                ? null
                : () => _showRejectDialog(schedule),
            onReschedule: isProcessing || !actionsEnabled
                ? null
                : () => _showRescheduleDialog(schedule),
          );
        },
      ),
    );
  }
}

class _ScheduleSecondaryFilterBar extends StatelessWidget {
  const _ScheduleSecondaryFilterBar({
    required this.propertyController,
    required this.visitDateLabel,
    required this.onVisitDateTap,
    required this.onClearFilters,
  });

  final TextEditingController propertyController;
  final String? visitDateLabel;
  final VoidCallback onVisitDateTap;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final labelStyle = theme.labelMedium?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );
    final fieldDecoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primaryLight.withValues(alpha: 0.35),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primaryLight.withValues(alpha: 0.35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final useStackedLayout = constraints.maxWidth < 560;

        final propertyField = _ScheduleFilterField(
          label: 'Property Name',
          labelStyle: labelStyle,
          child: TextField(
            controller: propertyController,
            decoration: fieldDecoration.copyWith(
              hintText: 'Filter by property...',
              hintStyle: theme.bodyMedium?.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.75),
              ),
            ),
            style: theme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textInputAction: TextInputAction.search,
          ),
        );

        final visitDateField = _ScheduleFilterField(
          label: 'Visit Date',
          labelStyle: labelStyle,
          child: InkWell(
            onTap: onVisitDateTap,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: fieldDecoration.copyWith(
                hintText: 'dd-mm-yyyy',
                hintStyle: theme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.75),
                ),
              ),
              child: Text(
                visitDateLabel ?? 'dd-mm-yyyy',
                style: theme.bodyMedium?.copyWith(
                  color: visitDateLabel == null
                      ? AppColors.textSecondary.withValues(alpha: 0.75)
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );

        final clearButton = Align(
          alignment: useStackedLayout
              ? Alignment.centerRight
              : Alignment.bottomCenter,
          child: TextButton(
            onPressed: onClearFilters,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            child: Text(
              'Clear Filters',
              style: theme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        );

        if (useStackedLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              propertyField,
              const SizedBox(height: 12),
              visitDateField,
              const SizedBox(height: 8),
              clearButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: propertyField),
            const SizedBox(width: 12),
            Expanded(child: visitDateField),
            const SizedBox(width: 8),
            clearButton,
          ],
        );
      },
    );
  }
}

class _ScheduleFilterField extends StatelessWidget {
  const _ScheduleFilterField({
    required this.label,
    required this.labelStyle,
    required this.child,
  });

  final String label;
  final TextStyle? labelStyle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _ScheduleFilterBar extends StatelessWidget {
  const _ScheduleFilterBar({
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: filters.map((filter) {
        final isSelected = filter == selectedFilter;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: filter != filters.last ? 8 : 0,
            ),
            child: Material(
              color: isSelected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => onFilterSelected(filter),
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primaryLight.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: Text(
                        filter,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.isProcessing,
    required this.processingAction,
    required this.onProperty,
    required this.onReport,
    required this.onViewReport,
    required this.onAccept,
    required this.onReject,
    required this.onReschedule,
  });

  final FieldAgentSchedule schedule;
  final bool isProcessing;
  final String? processingAction;
  final VoidCallback? onProperty;
  final VoidCallback? onReport;
  final VoidCallback? onViewReport;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onReschedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final status = schedule.normalizedStatus;
    final statusLabel = _formatLabel(schedule.status);

    final isAssigned = status == 'assigned';
    final isConfirmed = status == 'confirmed';
    final isCompleted = status == 'completed';

    final canSubmitReport = isAssigned ? schedule.canSubmitReport : true;
    final reportEnabled = (isConfirmed || isAssigned) && canSubmitReport;
    final actionsEnabled = schedule.actionButtonsEnabled;

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
            schedule.propertyName ?? '—',
            style: theme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 14),
          _ScheduleDetailRow(
            icon: Icons.home_repair_service_outlined,
            label: 'Visit Type',
            value: schedule.visitType,
          ),
          _ScheduleDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Scheduled Date',
            value: schedule.scheduledDate,
          ),
          _ScheduleDetailRow(
            icon: Icons.info_outline,
            label: 'Status',
            value: 'Status : $statusLabel',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: PremiumOutlineButton(
                  label: 'Property',
                  onPressed: onProperty,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isCompleted
                    ? PremiumPrimaryButton(
                        label: 'View Report',
                        onPressed: onViewReport,
                      )
                    : PremiumPrimaryButton(
                        label: 'Report',
                        onPressed: reportEnabled ? onReport : null,
                      ),
              ),
            ],
          ),
          if (isAssigned && !canSubmitReport) ...[
            const SizedBox(height: 8),
            Text(
              'Disabled until scheduled visit date',
              style: theme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (isAssigned) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Expanded(
                  child: _CompactActionButton(
                    label: isProcessing && processingAction == 'accept'
                        ? 'Accepting...'
                        : 'Accept',
                    onPressed: onAccept,
                    isLoading:
                        isProcessing && processingAction == 'accept',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CompactActionButton(
                    label: isProcessing && processingAction == 'reject'
                        ? 'Rejecting...'
                        : 'Reject',
                    onPressed: onReject,
                    isLoading:
                        isProcessing && processingAction == 'reject',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CompactActionButton(
                    label: isProcessing && processingAction == 'reschedule'
                        ? 'Submitting...'
                        : 'Reschedule',
                    onPressed: onReschedule,
                    isLoading:
                        isProcessing && processingAction == 'reschedule',
                  ),
                ),
              ],
            ),
            if (isAssigned && !actionsEnabled) ...[
              const SizedBox(height: 10),
              Text(
                'Actions are available from 3 days before until 3 days after the scheduled visit date.',
                style: theme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static String _formatLabel(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '—';
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }
}

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: onPressed == null
              ? AppColors.textSecondary.withValues(alpha: 0.6)
              : AppColors.primaryDark,
          disabledForegroundColor:
              AppColors.textSecondary.withValues(alpha: 0.45),
          side: BorderSide(
            color: onPressed == null
                ? AppColors.primaryLight.withValues(alpha: 0.35)
                : AppColors.primaryLight.withValues(alpha: 0.8),
          ),
          backgroundColor: onPressed == null
              ? AppColors.background.withValues(alpha: 0.6)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }
}

class _ScheduleDetailRow extends StatelessWidget {
  const _ScheduleDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final display = value?.trim().isNotEmpty == true ? value!.trim() : '—';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  display,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
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

class _RejectTaskDialog extends StatefulWidget {
  const _RejectTaskDialog({
    required this.onCancel,
    required this.onSubmit,
  });

  final VoidCallback onCancel;
  final Future<void> Function(String reason) onSubmit;

  @override
  State<_RejectTaskDialog> createState() => _RejectTaskDialogState();
}

class _RejectTaskDialogState extends State<_RejectTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String? _validateReason(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Reason is required.';
    if (trimmed.length < 10) return 'Minimum 10 characters.';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    await widget.onSubmit(_reasonController.text.trim());
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Reason *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              enabled: !_isSubmitting,
              maxLines: 4,
              validator: _validateReason,
              decoration: const InputDecoration(
                hintText: 'Enter reason for rejection',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : widget.onCancel,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}

class _RescheduleTaskDialog extends StatefulWidget {
  const _RescheduleTaskDialog({
    required this.onCancel,
    required this.onSubmit,
  });

  final VoidCallback onCancel;
  final Future<void> Function(String newDate, String reason) onSubmit;

  @override
  State<_RescheduleTaskDialog> createState() => _RescheduleTaskDialogState();
}

class _RescheduleTaskDialogState extends State<_RescheduleTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String? _validateReason(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Reason is required.';
    if (trimmed.length < 10) return 'Minimum 10 characters.';
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date is required.')),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final formatted = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    await widget.onSubmit(formatted, _reasonController.text.trim());
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _selectedDate == null
        ? 'Select date'
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    return AlertDialog(
      title: const Text('Request Reschedule'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('New Date *'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _isSubmitting ? null : _pickDate,
              child: Text(dateLabel),
            ),
            const SizedBox(height: 16),
            const Text('Reason *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              enabled: !_isSubmitting,
              maxLines: 4,
              validator: _validateReason,
              decoration: const InputDecoration(
                hintText: 'Enter reason for reschedule',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : widget.onCancel,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const Text('Submitting...')
              : const Text('Submit'),
        ),
      ],
    );
  }
}

class _ScheduleEmptyState extends StatelessWidget {
  const _ScheduleEmptyState();

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
                Icons.event_busy_outlined,
                size: 48,
                color: AppColors.primaryDark.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No schedules found.',
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
