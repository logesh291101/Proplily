import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/providers/client_feedback_provider.dart';
import 'package:proplilly/client/services/client_feedback_service.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/utils/form_validators.dart';
import 'package:proplilly/client/widgets/client_feedback/client_feedback_hero_section.dart';
import 'package:proplilly/client/widgets/client_feedback/client_feedback_history_section.dart';
import 'package:proplilly/client/widgets/client_feedback/client_feedback_star_rating.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/client_referral/client_referral_premium_field.dart';

/// Premium client feedback submission screen.
class ClientFeedbackScreen extends StatefulWidget {
  const ClientFeedbackScreen({super.key});

  @override
  State<ClientFeedbackScreen> createState() => _ClientFeedbackScreenState();
}

class _ClientFeedbackScreenState extends State<ClientFeedbackScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _messageController.clear();
    setState(() {
      _rating = 0;
      _formKey = GlobalKey<FormState>();
    });
  }

  void _showApiSnackBar({
    required String? message,
    required Color backgroundColor,
  }) {
    final text = message?.trim();
    if (text == null || text.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _onSubmit(ClientFeedbackProvider provider) async {
    FocusScope.of(context).unfocus();

    if (_rating < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating from 1 to 5 stars'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await provider.submitFeedback(
        rating: _rating,
        feedbackMessage: _messageController.text.trim(),
      );

      if (!mounted) return;

      switch (result) {
        case ClientFeedbackSuccess(:final message):
          _showApiSnackBar(
            message: message,
            backgroundColor: AppColors.success,
          );
        case ClientFeedbackFailure(:final message):
          _showApiSnackBar(
            message: message,
            backgroundColor: AppColors.error,
          );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _clearForm();
        await provider.refreshHistory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClientFeedbackProvider()..loadFeedbackHistory(),
      child: Builder(
        builder: (providerContext) {
          final horizontal = ScreenSpacing.horizontal(providerContext);
          final theme = Theme.of(providerContext).textTheme;
          final feedbackProvider =
              providerContext.watch<ClientFeedbackProvider>();

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: ProplillyAppBar.clientHeroOverlay(),
            body: Column(
              children: [

                const ClientFeedbackHeroSection(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding:
                        EdgeInsets.fromLTRB(horizontal, 0, horizontal, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height:20),
                        Transform.translate(
                          offset: Offset(
                            0,
                            -ScreenSpacing.floatingCardOverlap(
                              providerContext,
                            ),
                          ),
                          child: _FeedbackFormCard(
                            formKey: _formKey,
                            theme: theme,
                            messageController: _messageController,
                            rating: _rating,
                            onRatingChanged: (r) =>
                                setState(() => _rating = r),
                            isSubmitting: _isSubmitting,
                            onSubmit: () => _onSubmit(feedbackProvider),
                          ),
                        ),
                        const SizedBox(height: 22),
                        ClientFeedbackHistorySection(
                          isLoading: feedbackProvider.isLoadingHistory,
                          errorMessage: feedbackProvider.historyErrorMessage,
                          emptyMessage: feedbackProvider.emptyHistoryMessage,
                          entries: feedbackProvider.historyRecords,
                          onRetry: () => feedbackProvider.refreshHistory(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FeedbackFormCard extends StatelessWidget {
  const _FeedbackFormCard({
    required this.formKey,
    required this.theme,
    required this.messageController,
    required this.rating,
    required this.onRatingChanged,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextTheme theme;
  final TextEditingController messageController;
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.10),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: PremiumDecorations.iconTile(AppColors.primary),
                  child: const Icon(
                    Icons.feedback_outlined,
                    size: 20,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share Your Feedback',
                        style: theme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Help us improve your PropLilly experience',
                        style: theme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ClientFeedbackStarRating(
              key: ValueKey<int>(rating),
              rating: rating,
              onRatingChanged: onRatingChanged,
            ),
            const SizedBox(height: 24),
            ClientReferralPremiumField(
              controller: messageController,
              label: 'Your feedback',
              hint: 'Tell us your experience...',
              icon: Icons.chat_bubble_outline_rounded,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              validator: FormValidators.detailedMessage,
            ),
            const SizedBox(height: 26),
            PremiumPrimaryButton(
              label: 'Submit Feedback',
              icon: Icons.send_rounded,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
