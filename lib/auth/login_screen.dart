import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/auth/auth_role_router.dart';
import 'package:proplilly/auth/login_service.dart';
import 'package:proplilly/auth/forgot_password_screen.dart';
import 'package:proplilly/auth/signup_screen.dart';
import 'package:proplilly/client/widgets/proplilly_logo_badge.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _apiErrorMessage;

  final _loginService = LoginService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _apiErrorMessage = null;
    });

    LoginResult result;
    try {
      result = await _loginService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    if (!mounted) return;

    switch (result) {
      case LoginSuccess(:final message, :final role):
        setState(() => _apiErrorMessage = null);
        _emailController.clear();
        _passwordController.clear();
        final successText = message?.trim();
        if (successText != null && successText.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successText),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 600));
        }
        if (!mounted) return;

        final home = AuthRoleRouter.homeForRole(role);
        if (home == null) {
          setState(() {
            _apiErrorMessage =
                'Your account role is not supported in this app yet.';
          });
          return;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => home),
        );
      case LoginFailure(:final message):
        final errorText = message?.trim();
        setState(() {
          _apiErrorMessage =
              errorText != null && errorText.isNotEmpty ? errorText : null;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isDesktopLike = screenWidth >= 900;
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 44.0);
    final bannerHeight = (screenHeight * 0.33).clamp(220.0, 360.0);
    final logoSize = (screenWidth * 0.16).clamp(78.0, 118.0);
    final sectionGap = (screenHeight * 0.018).clamp(10.0, 22.0);
    final cardPadding = (screenWidth * 0.042).clamp(16.0, 28.0);
    final titleFont = (screenWidth * 0.046).clamp(20.0, 30.0);
    final bodyFont = (screenWidth * 0.033).clamp(13.0, 17.0);
    final buttonHeight = (screenHeight * 0.07).clamp(48.0, 58.0);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: bannerHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: AppColors.primaryDark),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ProplillyLogoBadge(size: logoSize),
                            SizedBox(height: sectionGap),
                            Text(
                              'Login to your account',
                              textAlign: TextAlign.center,
                              style: textTheme.titleLarge?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: titleFont,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: sectionGap),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  sectionGap,
                  horizontalPadding,
                  horizontalPadding,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isDesktopLike ? 640 : 560),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(cardPadding),
                        child: Form(
                            key: _formKey,
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autovalidateMode: AutovalidateMode.disabled,
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  hintStyle: TextStyle(fontSize: bodyFont),
                                  filled: false,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: sectionGap),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                autovalidateMode: AutovalidateMode.disabled,
                                decoration: InputDecoration(
                                  hintText: 'Password',
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
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: (sectionGap * 0.45).clamp(4.0, 10.0)),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push<void>(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: bodyFont - 1,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: (sectionGap * 0.7).clamp(8.0, 14.0)),
                              if (_apiErrorMessage != null &&
                                  _apiErrorMessage!.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.error.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _apiErrorMessage!,
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w600,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: sectionGap * 0.75),
                              ],
                              SizedBox(
                                height: buttonHeight,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : () => _handleLogin(),
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
                                          'Log in',
                                          style: TextStyle(
                                            fontSize: bodyFont,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: sectionGap),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Don’t have an account? ',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: bodyFont,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const SignUpScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Sign up',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: bodyFont,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
