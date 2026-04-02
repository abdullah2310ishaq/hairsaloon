import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/business_profile/presentation/state/business_profile_scope.dart';
import 'package:hairsaloon/src/features/router/app_routes.dart';
import 'package:hairsaloon/src/features/settings/data/local_tax_rate_store.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Design tokens (mirrors registration screen) ──────────────────────────────
class _C {
  static const bg = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF6F6F6);
  static const surfaceHigh = Color(0xFFECECEC);
  static const border = Color(0xFFE3E3E3);
  static const lime = Color(0xFFD4FF33);
  static const textPrimary = Color(0xFF0D0D0D);
  static const textSecondary = Color(0xFF6B6B6B);
  static const error = Color(0xFFFF5C5C);
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  static final Uri _intelligementUri = Uri.parse(
    'http://www.intelligement.com/',
  );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _C.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            _buildHeader(),

            const SizedBox(height: 8),

            // ── Menu list ────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                children: [
                  _SectionLabel('GENERAL'),
                  _Item(
                    icon: CupertinoIcons.person_crop_circle,
                    title: 'Profile Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.profileSettings);
                    },
                  ),
                  _Item(
                    icon: CupertinoIcons.person_2,
                    title: 'Customers',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed(AppRoutes.customers);
                    },
                  ),
                  const SizedBox(height: 10),
                  _SectionLabel('CATALOGUE'),
                  _Item(
                    icon: CupertinoIcons.list_bullet_indent,
                    title: 'Categories',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed(AppRoutes.categories);
                    },
                  ),
                  const SizedBox(height: 10),
                  _SectionLabel('FINANCE'),
                  _Item(
                    icon: CupertinoIcons.creditcard,
                    title: 'Expense List',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed(AppRoutes.expenses);
                    },
                  ),
                  _Item(
                    icon: CupertinoIcons.money_dollar_circle,
                    title: 'Currency Change',
                    onTap: () => Navigator.pop(context),
                  ),
                  _Item(
                    icon: CupertinoIcons.percent,
                    title: 'Tax Rate',
                    trailing: _TaxBadge(),
                    onTap: () async {
                      Navigator.pop(context);
                      await _showTaxRateDialog(context);
                    },
                  ),
                ],
              ),
            ),

            // ── Bottom: version + logout ──────────────────────────────────
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _C.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App icon + name row
          Row(
            children: [
              const Text("  "),
              const SizedBox(width: 60),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saloon Management',
                    style: TextStyle(
                      color: _C.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _C.border, width: 1)),
      ),
      child: Column(
        children: [
          // Logout button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: _C.error.withOpacity(0.08),
                foregroundColor: _C.error,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: _C.error.withOpacity(0.2), width: 1),
                ),
              ),
              onPressed: () => _handleLogout(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.square_arrow_left, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Made with ❤️ by ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
                InkWell(
                  onTap: _openIntelligementWebsite,
                  borderRadius: BorderRadius.circular(4),
                  child: const Text(
                    'Intelligement',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tax dialog ───────────────────────────────────────────────────────────
  Future<void> _showTaxRateDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: LocalTaxRateStore.taxRate.toStringAsFixed(0),
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _C.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Tax Rate',
          style: TextStyle(color: _C.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: _C.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter percentage e.g. 16',
            hintStyle: const TextStyle(color: _C.textSecondary),
            suffixText: '%',
            suffixStyle: const TextStyle(
              color: _C.lime,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: _C.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.lime, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _C.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.lime,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value == null || value < 0) {
                Navigator.of(dialogContext).pop();
                return;
              }
              setState(() => LocalTaxRateStore.setTaxRate(value));
              Navigator.of(dialogContext).pop();
            },
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openIntelligementWebsite() async {
    await launchUrl(_intelligementUri, mode: LaunchMode.externalApplication);
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> _handleLogout(BuildContext context) async {
    Navigator.pop(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _C.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(color: _C.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: _C.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _C.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await BusinessProfileScope.of(context).clear();
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.businessRegistration,
        (route) => false,
      );
    }
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _C.textSecondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

// ── Menu item ─────────────────────────────────────────────────────────────────

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: _C.lime.withOpacity(0.06),
          highlightColor: _C.lime.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _C.border, width: 1),
                  ),
                  child: Icon(icon, size: 17, color: _C.textSecondary),
                ),
                const SizedBox(width: 13),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _C.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
                // Trailing or chevron
                trailing ??
                    const Icon(
                      CupertinoIcons.chevron_right,
                      size: 13,
                      color: _C.textSecondary,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tax badge ─────────────────────────────────────────────────────────────────

class _TaxBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _C.surfaceHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _C.border, width: 1),
      ),
      child: Text(
        '${LocalTaxRateStore.taxRate.toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
