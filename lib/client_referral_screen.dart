import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/data/country_codes.dart';
import 'package:proplilly/models/country_code.dart';
import 'package:proplilly/providers/client_referral_provider.dart';
import 'package:proplilly/services/client_referral_service.dart';
import 'package:proplilly/theme/premium_decorations.dart';
import 'package:proplilly/theme/screen_spacing.dart';
import 'package:proplilly/utils/form_validators.dart';
import 'package:proplilly/widgets/client_referral/client_referral_code_card.dart';
import 'package:proplilly/widgets/client_referral/client_referral_hero_section.dart';
import 'package:proplilly/widgets/client_referral/client_referral_phone_field.dart';
import 'package:proplilly/widgets/client_referral/client_referral_premium_field.dart';
import 'package:proplilly/widgets/premium/premium_buttons.dart';

class ClientReferralScreen extends StatelessWidget {
  const ClientReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClientReferralProvider()..loadReferralCode(),
      child: const _ClientReferralView(),
    );
  }
}

class _ClientReferralView extends StatefulWidget {
  const _ClientReferralView();

  @override
  State<_ClientReferralView> createState() => _ClientReferralViewState();
}

class _ClientReferralViewState extends State<_ClientReferralView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  CountryCode _selectedCountry = CountryCodes.defaultCountry;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onCancel() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result =
        await context.read<ClientReferralProvider>().submitReferral(
              fullName: _fullNameController.text,
              email: _emailController.text,
              countryDialCode: _selectedCountry.dialCode,
              phoneNumber: _phoneController.text,
            );

    if (!mounted) return;

    switch (result) {
      case ClientReferralSubmitSuccess(:final message):
        final text = message?.trim();
        if (text != null && text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(text),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        Navigator.of(context).pop();
      case ClientReferralSubmitFailure(:final message):
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

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);
    final referralProvider = context.watch<ClientReferralProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const ClientReferralHeroSection(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Transform.translate(
                    offset: Offset(
                      0,
                      -ScreenSpacing.floatingCardOverlap(context),
                    ),
                    child: ClientReferralCodeCard(
                      isLoading: referralProvider.isLoadingCode,
                      errorMessage: referralProvider.errorMessage,
                      referralCode: referralProvider.referralCode,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _ClientReferralFormCard(
                    formKey: _formKey,
                    fullNameController: _fullNameController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    selectedCountry: _selectedCountry,
                    onCountryChanged: (c) => setState(() => _selectedCountry = c),
                    isSubmitting: referralProvider.isSubmitting,
                    onCancel: _onCancel,
                    onSubmit: _onSubmit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientReferralFormCard extends StatelessWidget {
  const _ClientReferralFormCard({
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.selectedCountry,
    required this.onCountryChanged,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onCountryChanged;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

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
                    Icons.person_add_alt_1_rounded,
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
                        'Referral Details',
                        style: theme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Who would you like to invite?',
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
            ClientReferralPremiumField(
              controller: fullNameController,
              label: 'Full Name',
              hint: 'Enter full name',
              icon: Icons.person_outline_rounded,
              validator: FormValidators.fullName,
            ),
            const SizedBox(height: 18),
            ClientReferralPremiumField(
              controller: emailController,
              label: 'Email Address',
              hint: 'name@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: FormValidators.email,
            ),
            const SizedBox(height: 18),
            ClientReferralPhoneField(
              phoneController: phoneController,
              selectedCountry: selectedCountry,
              onCountryChanged: onCountryChanged,
            ),
            const SizedBox(height: 28),
            _ClientReferralActionButtons(
              isSubmitting: isSubmitting,
              onCancel: onCancel,
              onSubmit: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientReferralActionButtons extends StatelessWidget {
  const _ClientReferralActionButtons({
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 400;

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumPrimaryButton(
            label: 'Submit Referral',
            icon: Icons.rocket_launch_rounded,
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : onSubmit,
          ),
          const SizedBox(height: 12),
          PremiumOutlineButton(
            label: 'Cancel',
            onPressed: isSubmitting ? null : onCancel,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: PremiumOutlineButton(
            label: 'Cancel',
            onPressed: isSubmitting ? null : onCancel,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: PremiumPrimaryButton(
            label: 'Submit Referral',
            icon: Icons.rocket_launch_rounded,
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : onSubmit,
          ),
        ),
      ],
    );
  }
}
