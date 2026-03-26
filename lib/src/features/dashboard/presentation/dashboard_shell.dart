import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:hairsaloon/src/features/billing/presentation/billing_screen.dart';
import 'package:hairsaloon/src/features/expenses/presentation/expenses_screen.dart';
import 'package:hairsaloon/src/features/appointments/presentation/appointments_screen.dart';
import 'package:hairsaloon/src/features/settings/presentation/app_drawer.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentIndex = 0;
  final NotchBottomBarController _notchController =
      NotchBottomBarController(index: 0);

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (_currentIndex) {
      0 => const DashboardScreen(),
      1 => const BillingScreen(),
      2 => const ExpensesScreen(),
      3 => const AppointmentsScreen(),
      _ => const DashboardScreen(),
    };

    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      body: body,
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _notchController,
        color: const Color(0xFFF7FFDF),
        showLabel: true,
        removeMargins: true,
        notchColor: AppColors.primary,
        kBottomRadius: 0,
        kIconSize: 22,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(
              CupertinoIcons.house,
              color: AppColors.textPrimary,
            ),
            activeItem: Icon(
              CupertinoIcons.house_fill,
              color: AppColors.textPrimary,
            ),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              CupertinoIcons.doc_plaintext,
              color: AppColors.textPrimary,
            ),
            activeItem: Icon(
              CupertinoIcons.doc_text_fill,
              color: AppColors.textPrimary,
            ),
            itemLabel: 'Billing',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              CupertinoIcons.money_dollar_circle,
              color: AppColors.textPrimary,
            ),
            activeItem: Icon(
              CupertinoIcons.money_dollar_circle_fill,
              color: AppColors.textPrimary,
            ),
            itemLabel: 'Expance',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              CupertinoIcons.calendar,
              color: AppColors.textPrimary,
            ),
            activeItem: Icon(
              CupertinoIcons.calendar_today,
              color: AppColors.textPrimary,
            ),
            itemLabel: 'Appointment',
          ),
        ],
        onTap: _onTap,
        itemLabelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

