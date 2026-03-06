import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/proplilly_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    _handleInitialNavigation();
  }

  Future<void> _handleInitialNavigation() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadAuthData();

    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    if (authProvider.isLoggedIn) {
      final user = authProvider.currentUser;
      if (user != null) {
        switch (user.userType) {
          case UserType.customer:
            context.go('/customer/dashboard');
            break;
          case UserType.coordinator:
            context.go('/coordinator/dashboard');
            break;
          case UserType.admin:
            context.go('/admin/dashboard');
            break;
        }
      } else {
        context.go('/login');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            );
          },
          child: const PropLillyLogo(height: 140, white: true),
        ),
      ),
    );
  }
}
