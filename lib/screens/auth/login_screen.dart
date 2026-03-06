import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/auth_theme.dart';
import '../../widgets/proplilly_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  UserType _selectedUserType = UserType.customer;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'logesh.k@rubixe.com');
    _passwordController = TextEditingController(text: 'welcome@21');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: _selectedUserType,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        final user = authProvider.currentUser;
        if (user != null) {
          switch (user.userType) {
            case UserType.customer:
              context.go('/home'); // Customer dashboard
              break;
            case UserType.coordinator:
              context.go('/coordinator/dashboard');
              break;
            case UserType.admin:
              context.go('/admin/dashboard');
              break;
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  Widget _buildRoleCard(UserType type, String title, IconData icon) {
    bool isSelected = _selectedUserType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedUserType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AuthTheme.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AuthTheme.primary : Colors.grey.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AuthTheme.primary : AuthTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AuthTheme.primary : AuthTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthTheme.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section with primary color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 48),
              decoration: AuthTheme.heroBackground(),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: PropLillyLogo(height: 70, white: true),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to manage your properties',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AuthTheme.authCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Login as:',
                        style: TextStyle(
                          color: AuthTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildRoleCard(UserType.customer, 'Customer', Icons.person_outline),
                          const SizedBox(width: 8),
                          _buildRoleCard(UserType.coordinator, 'Coordinator', Icons.handyman_outlined),
                          const SizedBox(width: 8),
                          _buildRoleCard(UserType.admin, 'Admin', Icons.admin_panel_settings_outlined),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AuthTheme.textPrimary),
                        decoration: AuthTheme.inputDecoration(
                          hintText: 'Email address',
                          prefixIcon: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AuthTheme.textPrimary),
                        decoration: AuthTheme.inputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AuthTheme.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() =>
                                  _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          style: TextButton.styleFrom(
                            foregroundColor: AuthTheme.primary,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: AuthTheme.primaryButton(),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Login'),
                      ),
                      const SizedBox(height:20),
                      // Row(
                      //   children: [
                      //     Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
                      //     const Padding(
                      //       padding: EdgeInsets.symmetric(horizontal: 16),
                      //       child: Text(
                      //         'OR',
                      //         style: TextStyle(
                      //           color: AuthTheme.textSecondary,
                      //           fontSize: 13,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
                      //   ],
                      // ),
                      // const SizedBox(height: 24),
                      // OutlinedButton(
                      //   onPressed: () {},
                      //   style: AuthTheme.socialButton(),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       const Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
                      //       const SizedBox(width: 8),
                      //       const Text(
                      //         'Continue with Google',
                      //         style: TextStyle(fontWeight: FontWeight.w600),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height:15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    color: AuthTheme.textSecondary,
                    fontSize: 15,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  style: TextButton.styleFrom(
                    foregroundColor: AuthTheme.primary,
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
