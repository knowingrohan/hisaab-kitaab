import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hisaab_kitaab/features/home/presentation/home_screen.dart';
import 'package:hisaab_kitaab/features/add_entry/presentation/add_items_sheet.dart';
import 'package:hisaab_kitaab/features/settings/presentation/settings_screen.dart';
import 'package:hisaab_kitaab/features/customer_detail/presentation/customer_detail_screen.dart';
import 'package:hisaab_kitaab/features/payment/presentation/record_payment_screen.dart';
import 'package:hisaab_kitaab/features/reminders/presentation/overdue_reminders_screen.dart';
import 'package:hisaab_kitaab/shared/widgets/bottom_nav_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'customer/:customerId',
                  name: 'customerDetail',
                  builder: (context, state) => CustomerDetailScreen(
                    customerId:
                        int.parse(state.pathParameters['customerId']!),
                  ),
                  routes: [
                    GoRoute(
                      path: 'payment',
                      name: 'recordPayment',
                      builder: (context, state) => RecordPaymentScreen(
                        customerId:
                            int.parse(state.pathParameters['customerId']!),
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'reminders',
                  name: 'overdueReminders',
                  builder: (context, state) =>
                      const OverdueRemindersScreen(),
                ),
              ],
            ),
          ],
        ),
        // Branch 1: Add Entry
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/add-entry',
              name: 'addEntry',
              builder: (context, state) => const AddItemsSheet(),
            ),
          ],
        ),
        // Branch 2: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
