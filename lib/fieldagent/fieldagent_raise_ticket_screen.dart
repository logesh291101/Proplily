import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/providers/client_support_ticket_provider.dart';
import 'package:proplilly/client/services/client_support_ticket_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/utils/form_validators.dart';
import 'package:proplilly/client/widgets/client_referral/client_referral_premium_field.dart';
import 'package:proplilly/client/widgets/client_support_ticket/client_support_ticket_category_field.dart';
import 'package:proplilly/client/widgets/ui/proplilly_screen_hero_section.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';

class FieldAgentRaiseTicketScreen extends StatelessWidget {
  const FieldAgentRaiseTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClientSupportTicketProvider(),
      child: const _FieldAgentRaiseTicketView(),
    );
  }
}

class _FieldAgentRaiseTicketView extends StatefulWidget {
  const _FieldAgentRaiseTicketView();

  @override
  State<_FieldAgentRaiseTicketView> createState() =>
      _FieldAgentRaiseTicketViewState();
}

class _FieldAgentRaiseTicketViewState extends State<_FieldAgentRaiseTicketView> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String? _selectedCategory;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result =
        await context.read<ClientSupportTicketProvider>().submitTicket(
              subject: _subjectController.text,
              category: _selectedCategory!,
              message: _messageController.text,
            );

    if (!mounted) return;

    switch (result) {
      case ClientSupportTicketSuccess(:final message):
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
        _clearForm();
      case ClientSupportTicketFailure(:final message):
        final text = message?.trim();
        if (text != null && text.isNotEmpty) {
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

  void _clearForm() {
    _subjectController.clear();
    _messageController.clear();
    setState(() {
      _selectedCategory = null;
      _formKey = GlobalKey<FormState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);
    final theme = Theme.of(context).textTheme;
    final isSubmitting =
        context.watch<ClientSupportTicketProvider>().isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProplillyAppBar.heroOverlay(),
      body: Column(
        children: [
          const ProplillyScreenHeroSection(
            title: 'Raise Support Ticket',
            subtitle: 'Get assistance with schedules, reports, or app issues.',
            icon: Icons.support_agent_outlined,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 22),
                  _FieldAgentSubmitTicketCard(
                    formKey: _formKey,
                    theme: theme,
                    subjectController: _subjectController,
                    messageController: _messageController,
                    selectedCategory: _selectedCategory,
                    onCategoryChanged: (v) =>
                        setState(() => _selectedCategory = v),
                    isSubmitting: isSubmitting,
                    onSubmit: _onSubmit,
                  ),
                  const SizedBox(height: 22),
                  //const ClientSupportTicketAssistanceCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldAgentSubmitTicketCard extends StatelessWidget {
  const _FieldAgentSubmitTicketCard({
    required this.formKey,
    required this.theme,
    required this.subjectController,
    required this.messageController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextTheme theme;
  final TextEditingController subjectController;
  final TextEditingController messageController;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
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
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
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
                    Icons.confirmation_number_outlined,
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
                        'Submit a Ticket',
                        style: theme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // Text(
                      //   'Beta • Response within 24 hours',
                      //   style: theme.bodySmall?.copyWith(
                      //     color: AppColors.textSecondary,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 14),
            // Text(
            //   'Need more specific help? Tell us what you need and our team '
            //   'will get back to you.',
            //   style: theme.bodyMedium?.copyWith(
            //     color: AppColors.textSecondary,
            //     height: 1.45,
            //   ),
            // ),
            const SizedBox(height: 22),
            ClientReferralPremiumField(
              controller: subjectController,
              label: 'Subject',
              hint: 'What do you need help with?',
              icon: Icons.subject_outlined,
              validator: (v) =>
                  FormValidators.requiredField(v, fieldName: 'a subject'),
            ),
            const SizedBox(height: 18),
            ClientSupportTicketCategoryField(
              key: ValueKey<String?>(selectedCategory),
              value: selectedCategory,
              onChanged: onCategoryChanged,
            ),
            const SizedBox(height: 18),
            ClientReferralPremiumField(
              controller: messageController,
              label: 'Detailed Message',
              hint: 'Please provide as much detail as possible...',
              icon: Icons.message_outlined,
              textInputAction: TextInputAction.newline,
              maxLines: 4,
              validator: FormValidators.detailedMessage,
            ),
            const SizedBox(height: 26),
            PremiumPrimaryButton(
              label: 'Submit Ticket',
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
