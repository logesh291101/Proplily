import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_screen_scaffold.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedule_property_detail_service.dart';
import 'package:proplilly/fieldagent/fieldagent_submit_report_service.dart';
import 'package:proplilly/fieldagent/my_schedule_property_detail_model.dart';

class FieldAgentSubmitReportScreen extends StatefulWidget {
  const FieldAgentSubmitReportScreen({
    super.key,
    required this.taskId,
  });

  final String taskId;

  @override
  State<FieldAgentSubmitReportScreen> createState() =>
      _FieldAgentSubmitReportScreenState();
}

class _FieldAgentSubmitReportScreenState
    extends State<FieldAgentSubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final FieldAgentMySchedulePropertyDetailService _detailService =
      FieldAgentMySchedulePropertyDetailService();
  final FieldAgentSubmitReportService _submitService =
      FieldAgentSubmitReportService();

  bool _isLoadingDetail = true;
  bool _isSubmitting = false;
  String? _detailErrorMessage;
  MySchedulePropertyDetail? _detail;
  String? _imageValidationError;

  List<File> _propertyImages = [];
  File? _propertyVideo;
  String? _videoFileName;

  static const _allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  static const _allowedVideoExtensions = ['mp4', 'webm', 'mov'];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoadingDetail = true;
      _detailErrorMessage = null;
    });

    final result = await _detailService.fetchTaskDetail(widget.taskId);
    if (!mounted) return;

    switch (result) {
      case MySchedulePropertyDetailFetchSuccess(:final model):
        setState(() {
          _detail = model.data;
          _isLoadingDetail = false;
        });
      case MySchedulePropertyDetailFetchFailure(:final message):
        setState(() {
          _detailErrorMessage = message;
          _isLoadingDetail = false;
        });
    }
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedImageExtensions,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return;

    final picked = <File>[];
    for (final file in result.files) {
      if (file.path == null) continue;
      final extension = file.extension?.toLowerCase();
      if (extension != null && _allowedImageExtensions.contains(extension)) {
        picked.add(File(file.path!));
      }
    }

    if (picked.isEmpty) return;

    setState(() {
      _propertyImages = [..._propertyImages, ...picked];
      _imageValidationError = null;
    });
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedVideoExtensions,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    final extension = file.extension?.toLowerCase();
    if (extension == null || !_allowedVideoExtensions.contains(extension)) {
      return;
    }

    setState(() {
      _propertyVideo = File(file.path!);
      _videoFileName = file.name;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _propertyImages = List<File>.from(_propertyImages)..removeAt(index);
    });
  }

  void _removeVideo() {
    setState(() {
      _propertyVideo = null;
      _videoFileName = null;
    });
  }

  String? _validateVisitComment(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Visit comment is required.';
    }
    if (trimmed.length < 10) {
      return 'Please enter at least 10 characters.';
    }
    return null;
  }

  bool _validateImages() {
    if (_propertyImages.isNotEmpty) {
      setState(() => _imageValidationError = null);
      return true;
    }
    setState(() {
      _imageValidationError = 'At least one property photo is required.';
    });
    return false;
  }

  Future<void> _submitReport() async {
    FocusScope.of(context).unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final hasImages = _validateImages();
    if (!isFormValid || !hasImages) return;

    setState(() => _isSubmitting = true);

    final result = await _submitService.submitReport(
      taskId: widget.taskId,
      reportComment: _commentController.text,
      propertyImages: _propertyImages,
      propertyVideo: _propertyVideo,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case FieldAgentSubmitReportSuccess(:final model):
        final message = model.message?.trim().isNotEmpty == true
            ? model.message!.trim()
            : 'Report submitted successfully.';
        await Fluttertoast.showToast(msg: message);
        if (!mounted) return;
        Navigator.of(context).pop();
      case FieldAgentSubmitReportFailure(:final message):
        final text = message.trim().isNotEmpty
            ? message
            : 'Failed to submit report.';
        await Fluttertoast.showToast(msg: text);
    }
  }

  String _buildHeaderSubtitle(MySchedulePropertyDetail detail) {
    final name = detail.propertyName?.trim() ?? '';
    final address = detail.address?.trim() ?? '';
    final city = detail.city?.trim() ?? '';
    final location = [address, city].where((part) => part.isNotEmpty).join(', ');

    if (name.isEmpty && location.isEmpty) return '—';
    if (name.isEmpty) return location;
    if (location.isEmpty) return name;
    return '$name · $location';
  }

  @override
  Widget build(BuildContext context) {
    return FieldAgentScreenScaffold(
      title: 'Submit Visit Report',
      subtitle: 'Submit inspection photos and notes for a task.',
      icon: Icons.assignment_outlined,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoadingDetail) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_detailErrorMessage != null) {
      return PremiumErrorState(
        message: _detailErrorMessage!,
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
    final theme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Submit Visit Report',
              style: theme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _buildHeaderSubtitle(detail),
              style: theme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Point of Contact',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.accountManagerName?.trim().isNotEmpty == true
                        ? detail.accountManagerName!.trim()
                        : '—',
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ContactLine(
                    icon: Icons.phone_outlined,
                    value: detail.accountManagerPhone,
                  ),
                  const SizedBox(height: 8),
                  _ContactLine(
                    icon: Icons.email_outlined,
                    value: detail.accountManagerEmail,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Property Photos *',
                    style: theme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PremiumOutlineButton(
                    label: 'Select Images',
                    onPressed: _isSubmitting ? null : _pickImages,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload one or more clear photos.',
                    style: theme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_imageValidationError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _imageValidationError!,
                      style: theme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (_propertyImages.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_propertyImages.length, (index) {
                        return _SelectedImageTile(
                          file: _propertyImages[index],
                          onRemove: _isSubmitting
                              ? null
                              : () => _removeImage(index),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video (Optional)',
                    style: theme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PremiumOutlineButton(
                    label: 'Select Video',
                    onPressed: _isSubmitting ? null : _pickVideo,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please upload in MP4, WebM, or MOV for the best '
                    'compatibility. Legacy formats like AVI are not supported.',
                    style: theme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  if (_propertyVideo != null) ...[
                    const SizedBox(height: 12),
                    _SelectedVideoTile(
                      fileName: _videoFileName ?? _propertyVideo!.path
                          .split(Platform.pathSeparator)
                          .last,
                      onRemove: _isSubmitting ? null : _removeVideo,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visit Comment *',
                    style: theme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _commentController,
                    enabled: !_isSubmitting,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText:
                          'Describe what you observed during the visit '
                          '(minimum 10 characters).',
                      alignLabelWithHint: true,
                    ),
                    validator: _validateVisitComment,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            PremiumPrimaryButton(
              label: _isSubmitting ? 'Submitting...' : 'Submit Report',
              icon: Icons.send_rounded,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submitReport,
            ),
          ],
        ),
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

class _SelectedImageTile extends StatelessWidget {
  const _SelectedImageTile({
    required this.file,
    required this.onRemove,
  });

  final File file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            file,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
        ),
        if (onRemove != null)
          Positioned(
            right: 2,
            top: 2,
            child: Material(
              color: AppColors.white.withValues(alpha: 0.92),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SelectedVideoTile extends StatelessWidget {
  const _SelectedVideoTile({
    required this.fileName,
    required this.onRemove,
  });

  final String fileName;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.videocam_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fileName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
        ],
      ),
    );
  }
}
