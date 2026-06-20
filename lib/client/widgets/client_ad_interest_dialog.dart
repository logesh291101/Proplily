import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_ads_model.dart';
import 'package:proplilly/client/services/client_ads_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';

Future<void> showClientAdInterestDialog(
  BuildContext context, {
  required ClientAdData ad,
  ClientAdsService? adsService,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return _ClientAdInterestDialog(
        ad: ad,
        adsService: adsService ?? ClientAdsService(),
      );
    },
  );
}

class _ClientAdInterestDialog extends StatefulWidget {
  const _ClientAdInterestDialog({
    required this.ad,
    required this.adsService,
  });

  final ClientAdData ad;
  final ClientAdsService adsService;

  @override
  State<_ClientAdInterestDialog> createState() =>
      _ClientAdInterestDialogState();
}

class _ClientAdInterestDialogState extends State<_ClientAdInterestDialog> {
  final _notesController = TextEditingController();
  String? _selectedResponse;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an interest response.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final adId = widget.ad.id?.trim();
    if (adId == null || adId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad ID is not available.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await widget.adsService.submitInterest(
      adId: adId,
      interestResponse: _selectedResponse!,
      interestNotes: _notesController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case ClientAdInterestSuccess(:final message):
        Navigator.of(context).pop();
        final text = message?.trim();
        if (text != null && text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(text),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      case ClientAdInterestFailure(:final message):
        final text = message.trim();
        if (text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(text),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final ctaLabel = widget.ad.ctaText?.trim();

    return AlertDialog(
      title: const Text('Ad Response'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ctaLabel != null && ctaLabel.isNotEmpty) ...[
              Text(
                ctaLabel,
                style: theme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<String>(
              value: _selectedResponse,
              decoration: InputDecoration(
                labelText: 'Interest Response',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'yes', child: Text('Yes')),
                DropdownMenuItem(value: 'no', child: Text('No')),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _selectedResponse = value),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _notesController,
              enabled: !_isSubmitting,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
