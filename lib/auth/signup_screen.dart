import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/auth/register_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  /// Bumped after submit so [Form] remounts with fresh validation state (without using [FormState.reset], which restores text).
  int _formRemountKey = 0;
  bool _isLoading = false;

  final _registerService = RegisterService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendLink() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      final result = await _registerService.register(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      switch (result) {
        case RegisterSuccess(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        case RegisterFailure(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } finally {
      if (mounted) {
        _emailController.clear();
        setState(() {
          _isLoading = false;
          _formRemountKey++;
        });
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
      appBar: AppBar(title: const Text('Sign Up')),
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
                  child: KeyedSubtree(
                    key: ValueKey(_formRemountKey),
                    child: Form(
                      key: _formKey,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      Text(
                        'Create Account',
                        style: textTheme.headlineSmall?.copyWith(
                          fontSize: titleFont,
                        ),
                      ),
                      SizedBox(height: (sectionGap * 0.6).clamp(8.0, 14.0)),
                      Text(
                        'Enter your email address and we’ll send you a link to create your account.',
                        style: textTheme.bodyMedium?.copyWith(fontSize: bodyFont),
                      ),
                      SizedBox(height: sectionGap),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.disabled,
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
                          onPressed:
                              _isLoading ? null : () => _handleSendLink(),
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
                                  'Send Link',
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
      ),
    );
  }
}
