import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:hairsaloon/src/features/billing/presentation/billing_screen.dart';
import 'package:hairsaloon/src/features/expenses/presentation/expenses_screen.dart';
import 'package:hairsaloon/src/features/settings/presentation/app_drawer.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentIndex = 0;

  void _onTap(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final body = switch (_currentIndex) {
      0 => const DashboardScreen(),
      1 => const BillingScreen(),
      2 => const ExpensesScreen(),
      _ => const DashboardScreen(),
    };

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBackPressed();
      },
      child: Scaffold(
        extendBody: true,
        drawer: const AppDrawer(),
        body: body,
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }

  void _handleBackPressed() {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return;
    }
    _showExitDialog();
  }

  Future<void> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Exit App',
          style: TextStyle(
            color: Color(0xFFF5F5F5),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to exit the app?',
          style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8A8A8A)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Exit',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (shouldExit == true && mounted) Navigator.of(context).pop();
  }
}

// ── Custom Bottom Nav ─────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const _navItems = [
  _NavItem(
    icon: CupertinoIcons.house,
    activeIcon: CupertinoIcons.house_fill,
    label: 'Home',
  ),
  _NavItem(
    icon: CupertinoIcons.doc_plaintext,
    activeIcon: CupertinoIcons.doc_text_fill,
    label: 'Billing',
  ),
  _NavItem(
    icon: CupertinoIcons.money_dollar_circle,
    activeIcon: CupertinoIcons.money_dollar_circle_fill,
    label: 'Expense',
  ),
];

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 12,
          bottom: bottomPadding > 0 ? bottomPadding : 14,
        ),
        child: Row(
          children: List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final isActive = i == currentIndex;
            // Responsive: divide available width equally
            final itemWidth = screenWidth / _navItems.length;

            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: itemWidth,
                child: _NavTile(item: item, isActive: isActive),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.isActive});

  final _NavItem item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active pill indicator + icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withOpacity(0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              isActive ? item.activeIcon : item.icon,
              size: 22,
              color: isActive ? Colors.black : const Color(0xFFAAAAAA),
            ),
          ),
          const SizedBox(height: 3),
          // Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.black : const Color(0xFFAAAAAA),
              letterSpacing: 0.1,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}
