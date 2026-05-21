import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hisaab_kitaab/core/auth/auth_provider.dart';
import 'package:hisaab_kitaab/core/auth/user_role.dart';
import 'package:hisaab_kitaab/features/onboarding/providers/onboarding_provider.dart';
import 'package:hisaab_kitaab/features/add_entry/presentation/add_entry_screen.dart';
import 'package:hisaab_kitaab/features/auth/presentation/login_screen.dart';
import 'package:hisaab_kitaab/features/auth/presentation/registration_screen.dart';
import 'package:hisaab_kitaab/features/customer_detail/presentation/customer_detail_screen.dart';
import 'package:hisaab_kitaab/features/home/presentation/home_screen.dart';
import 'package:hisaab_kitaab/features/onboarding/presentation/onboarding_screen.dart';
import 'package:hisaab_kitaab/features/payment/presentation/record_payment_screen.dart';
import 'package:hisaab_kitaab/features/reminders/presentation/overdue_reminders_screen.dart';
import 'package:hisaab_kitaab/features/customer_detail/presentation/pdf_report_screen.dart';
import 'package:hisaab_kitaab/features/customer_home/presentation/customer_home_screen.dart';
import 'package:hisaab_kitaab/features/settings/presentation/pending_customers_screen.dart';
import 'package:hisaab_kitaab/features/settings/presentation/settings_screen.dart';
import 'package:hisaab_kitaab/features/staff/presentation/staff_settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Listenable wrapper so GoRouter re-evaluates redirect on auth/onboarding changes.
class _AuthNotifierListenable extends ChangeNotifier {
  _AuthNotifierListenable(ProviderContainer container) {
    container.listen<HKAuthState>(authProvider, (prev, next) => notifyListeners());
    container.listen<bool?>(onboardingDoneProvider, (prev, next) {
      if (prev != next) notifyListeners();
    });
  }
}

GoRouter buildAppRouter(ProviderContainer container) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: _AuthNotifierListenable(container),
    redirect: (context, state) {
      final auth = container.read(authProvider);
      final loc = state.matchedLocation;

      // Still resolving — don't redirect
      if (auth is HKAuthLoading) return null;

      final isLoggedIn = auth is HKAuthAuthenticated;
      final isOnLogin = loc == '/login';
      final isOnRegister = loc == '/register';

      // Not logged in → send to login (allow register screen for pre-auth flow)
      if (!isLoggedIn && !isOnLogin && !isOnRegister) return '/login';

      // Logged in → never show the login screen
      if (isLoggedIn && isOnLogin) return '/';

      if (auth is! HKAuthAuthenticated) return null;

      final role = auth.role;
      final isOnOnboarding = loc == '/onboarding';

      // UnknownRole users must complete registration
      if (role is UnknownRole && !isOnRegister) return '/register';

      // Known roles don't need the register screen
      if (role is! UnknownRole && isOnRegister) return '/';

      // Non-owners must not access onboarding
      if (role is! OwnerRole && isOnOnboarding) return '/';

      // OwnerRole: redirect to onboarding if not yet complete
      if (role is OwnerRole) {
        final onboardingDone = container.read(onboardingDoneProvider);
        if (onboardingDone == false && !isOnOnboarding) return '/onboarding';
      }

      // CustomerRole users land on their own home screen
      if (role is CustomerRole && loc == '/') return '/customer-home';

      // Non-customer roles must not access the customer home screen
      if (role is! CustomerRole && loc == '/customer-home') return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/customer-home',
        name: 'customerHome',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'customer/:customerId',
            name: 'customerDetail',
            builder: (context, state) => CustomerDetailScreen(
              customerId: state.pathParameters['customerId']!,
            ),
            routes: [
              GoRoute(
                path: 'payment',
                name: 'recordPayment',
                builder: (context, state) => RecordPaymentScreen(
                  customerId: state.pathParameters['customerId']!,
                ),
              ),
              GoRoute(
                path: 'report',
                name: 'pdfReport',
                builder: (context, state) => PdfReportScreen(
                  customerId: state.pathParameters['customerId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'add-entry',
            name: 'addEntry',
            builder: (context, state) => const AddEntryScreen(),
          ),
          GoRoute(
            path: 'reminders',
            name: 'overdueReminders',
            builder: (context, state) => const OverdueRemindersScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'staff',
            name: 'staffSettings',
            builder: (context, state) => const StaffSettingsScreen(),
          ),
          GoRoute(
            path: 'pending-customers',
            name: 'pendingCustomers',
            builder: (context, state) => const PendingCustomersScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Provider so the router can be accessed from anywhere in the widget tree.
final appRouterProvider = Provider<GoRouter>((ref) {
  final container = ProviderScope.containerOf(
    _rootNavigatorKey.currentContext!,
  );
  return buildAppRouter(container);
});
