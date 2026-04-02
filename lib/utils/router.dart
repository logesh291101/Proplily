import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../screens/landing/splash_screen.dart';
import '../screens/landing/home_screen.dart';
import '../screens/landing/about_screen.dart';
import '../screens/landing/services_screen.dart';
import '../screens/landing/testimonials_screen.dart';
import '../screens/landing/profile_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/admin/add_coordinator_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/coordinator/coordinator_dashboard.dart';
import '../screens/coordinator/coordinator_add_property_screen.dart';
import '../screens/coordinator/submit_report_screen.dart';
import '../screens/property_owner/property_owner_dashboard.dart';
import '../screens/property_owner/add_property_screen.dart';
import '../screens/property_owner/subscription_plan_screen.dart';
import '../screens/property_owner/plan_billing_screen.dart';
import '../screens/property_owner/support_center_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_add_property_screen.dart';
import '../screens/admin/property_review_dashboard.dart';
import '../screens/admin/coordinator_management_dashboard.dart';
import '../screens/admin/customers_list_screen.dart';
import '../screens/admin/coordinators_list_screen.dart';
import '../screens/admin/plans_subscribers_screen.dart';
import '../screens/admin/visit_tracking_dashboard.dart';
import '../screens/admin/emergency_dashboard.dart';
import '../screens/admin/subscription_billing_manager.dart';
import '../screens/admin/service_request_manager.dart';
import '../screens/admin/reports_dashboard.dart';
import '../screens/admin/property_assignment_screen.dart';

/// Landing app router - Splash → Login → Home
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => const ServicesScreen(),
    ),
    GoRoute(
      path: '/testimonials',
      builder: (context, state) => const TestimonialsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otp-verification',
      builder: (context, state) {
        if (state.extra is Map) {
          final data = state.extra as Map<String, dynamic>;
          return OTPVerificationScreen(
            email: data['email'] as String,
            isForgotPassword: data['isForgotPassword'] ?? false,
          );
        }
        final email = state.extra as String;
        return OTPVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ResetPasswordScreen(
          email: data['email'],
        );
      },
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    // Property Owner / Customer Routes
    GoRoute(
      path: '/customer/dashboard',
      builder: (context, state) => const PropertyOwnerDashboard(),
    ),
    GoRoute(
      path: '/property-owner/subscription',
      builder: (context, state) => const SubscriptionPlanScreen(),
    ),
    GoRoute(
      path: '/property-owner/add-property',
      builder: (context, state) => const AddPropertyScreen(),
    ),
    GoRoute(
      path: '/property-owner/plan-billing',
      builder: (context, state) => const PlanBillingScreen(),
    ),
    GoRoute(
      path: '/property-owner/support',
      builder: (context, state) => const SupportCenterScreen(),
    ),
    GoRoute(
      path: '/property-owner/property/:id',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Property Details')),
        body: Center(child: Text('Details for Property ID: ${state.pathParameters['id']}')),
      ),
    ),
    // Coordinator Routes
    GoRoute(
      path: '/coordinator/dashboard',
      builder: (context, state) => const CoordinatorDashboard(),
    ),
    GoRoute(
      path: '/coordinator/add-property',
      builder: (context, state) => const CoordinatorAddPropertyScreen(),
    ),
    GoRoute(
      path: '/coordinator/submit-report',
      builder: (context, state) {
        final prop = state.extra as Property?;
        return SubmitReportScreen(preselectedProperty: prop);
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    // Admin Routes
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/admin/add-property',
      builder: (context, state) => const AdminAddPropertyScreen(),
    ),
    GoRoute(
      path: '/admin/add-coordinator',
      builder: (context, state) => const AddCoordinatorScreen(),
    ),
    GoRoute(
      path: '/admin/property-review',
      builder: (context, state) => const PropertyReviewDashboard(),
    ),
    GoRoute(
      path: '/admin/customers',
      builder: (context, state) => const CustomersListScreen(),
    ),
    GoRoute(
      path: '/admin/coordinators',
      builder: (context, state) => const CoordinatorsListScreen(),
    ),
    GoRoute(
      path: '/admin/plans-subscribers',
      builder: (context, state) => const PlansSubscribersScreen(),
    ),
    GoRoute(
      path: '/admin/visits',
      builder: (context, state) => const VisitTrackingDashboard(),
    ),
    GoRoute(
      path: '/admin/emergency',
      builder: (context, state) => const EmergencyDashboard(),
    ),
    GoRoute(
      path: '/admin/billing',
      builder: (context, state) => const SubscriptionBillingManager(),
    ),
    GoRoute(
      path: '/admin/services',
      builder: (context, state) => const ServiceRequestManager(),
    ),
    GoRoute(
      path: '/admin/reports',
      builder: (context, state) => const ReportsDashboard(),
    ),
    GoRoute(
      path: '/admin/assign-property',
      builder: (context, state) {
        final helper = state.extra as User;
        return PropertyAssignmentScreen(coordinator: helper);
      },
    ),
    // Alias for properties/projects/contact - handled as tabs in HomeScreen
    GoRoute(
      path: '/properties',
      redirect: (context, state) => '/home',
    ),
    GoRoute(
      path: '/projects',
      redirect: (context, state) => '/home',
    ),
    GoRoute(
      path: '/contact',
      redirect: (context, state) => '/home',
    ),
  ],
);
