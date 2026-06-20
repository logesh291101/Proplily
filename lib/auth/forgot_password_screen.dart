import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/auth/reset_password_screen.dart';
import 'package:proplilly/auth/forgot_password_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  final _service = ForgotPasswordService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final email = _emailController.text.trim();

    setState(() => _isLoading = true);

    ForgotPasswordResult result;
    try {
      result = await _service.sendOtp(email: email);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    if (!mounted) return;

    switch (result) {
      case ForgotPasswordSuccess(:final message):
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
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => ResetPasswordScreen(email: email),
          ),
        );
      case ForgotPasswordFailure(:final message):
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
      appBar: AppBar(title: const Text('Forgot Password')),
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
                          'Enter your email address. We will send a one-time code to reset your password.',
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: bodyFont,
                          ),
                        ),
                        SizedBox(height: sectionGap),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            if (!_isLoading) _sendOtp();
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            hintText: 'Email address',
                            hintStyle: TextStyle(fontSize: bodyFont),
                            filled: false,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: sectionGap),
                        SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendOtp,
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
                                    'Send OTP',
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
