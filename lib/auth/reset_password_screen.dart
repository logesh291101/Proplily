import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/auth/login_screen.dart';
import 'package:proplilly/auth/reset_password_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final _service = ResetPasswordService();

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    ResetPasswordResult result;
    try {
      result = await _service.reset(
        email: widget.email.trim(),
        otp: _otpController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!mounted) return;

    switch (result) {
      case ResetPasswordSuccess(:final message):
        final text = message?.trim();
        if (text != null && text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(text),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 600));
        }
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil<void>(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      case ResetPasswordFailure(:final message):
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
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isDesktopLike = screenWidth >= 900;
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 44.0);
    final topSpacing = (screenHeight * 0.04).clamp(16.0, 36.0);
    final cardPadding = (screenWidth * 0.042).clamp(16.0, 28.0);
    final titleFont = (screenWidth * 0.046).clamp(20.0, 30.0);
    final bodyFont = (screenWidth * 0.033).clamp(13.0, 17.0);
    final buttonHeight = (screenHeight * 0.07).clamp(48.0, 58.0);
    final sectionGap = (screenHeight * 0.018).clamp(10.0, 22.0);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topSpacing,
            horizontalPadding,
            horizontalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktopLike ? 640 : 560),
              child: Card(
                color: AppColors.white,
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Reset your password',
                          style: textTheme.headlineSmall?.copyWith(
                            fontSize: titleFont,
                          ),
                        ),
                        SizedBox(height: (sectionGap * 0.6).clamp(8.0, 14.0)),
                        Text(
                          'Enter the 6-digit code sent to ${widget.email.trim()} and choose a new password.',
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: bodyFont,
                          ),
                        ),
                        SizedBox(height: sectionGap),
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(
                            hintText: '6-digit OTP',
                            hintStyle: TextStyle(fontSize: bodyFont),
                            filled: false,
                            counterText: '',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.length != 6) {
                              return 'OTP must be exactly 6 digits';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: sectionGap),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            hintText: 'New password',
                            hintStyle: TextStyle(fontSize: bodyFont),
                            filled: false,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: sectionGap),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            hintText: 'Confirm password',
                            hintStyle: TextStyle(fontSize: bodyFont),
                            filled: false,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                );
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: sectionGap),
                        SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? SizedBox(
                                    height: bodyFont + 8,
                                    width: bodyFont + 8,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: bodyFont,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
