import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/business_profile/presentation/state/business_profile_scope.dart';
import 'package:hairsaloon/src/features/router/app_routes.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = BusinessProfileScope.of(context).profile;
    final businessName = (profile?.businessName.trim().isNotEmpty ?? false)
        ? profile!.businessName
        : 'Sarfaraz Hair Salon';
    final address = (profile?.address.trim().isNotEmpty ?? false)
        ? profile!.address
        : (profile != null && profile.area.trim().isNotEmpty)
        ? '${profile.area}, ${profile.city}'
        : 'G-11 Markaz, Islamabad';

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(CupertinoIcons.bars),
                      color: Colors.white,
                    );
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  businessName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  address,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              _TodayAppointmentsCard(
                countText: '05',
                onViewAll: () =>
                    Navigator.of(context).pushNamed(AppRoutes.appointments),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _DashboardTile(
                    label: 'Finance',
                    assetPath: 'assets/finance.png',
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.financeOverview),
                  ),
                  _DashboardTile(
                    label: 'Employees',
                    assetPath: 'assets/employees.png',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.employees),
                  ),
                  _DashboardTile(
                    label: 'Rate List',
                    assetPath: 'assets/ratelust.png',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.serviceList),
                  ),
                  _DashboardTile(
                    label: 'Customers',
                    assetPath: 'assets/customers.png',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.customers),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayAppointmentsCard extends StatelessWidget {
  const _TodayAppointmentsCard({
    required this.countText,
    required this.onViewAll,
  });

  final String countText;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today Appointments',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                        color: Colors.white,
                      ),
                      child: const Icon(
                        CupertinoIcons.clock,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      countText,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF222222),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onViewAll,
            icon: const Icon(CupertinoIcons.eye, size: 16),
            label: const Text(
              'View All',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.label,
    required this.assetPath,
    required this.onTap,
  });

  final String label;
  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const tileRadius = 12.0;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(tileRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(tileRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 106,
                height: 106,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(tileRadius),
                  child: Image.asset(assetPath, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
