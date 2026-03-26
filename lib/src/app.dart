import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/appointments/presentation/appointments_screen.dart';
import 'package:hairsaloon/src/features/auth/presentation/business_registration_screen.dart';
import 'package:hairsaloon/src/features/auth/presentation/login_screen.dart';
import 'package:hairsaloon/src/features/billing/presentation/bill_details_screen.dart';
import 'package:hairsaloon/src/features/billing/presentation/saved_bills_screen.dart';
import 'package:hairsaloon/src/features/business_profile/data/repositories/shared_prefs_business_profile_repository.dart';
import 'package:hairsaloon/src/features/business_profile/domain/usecases/clear_business_profile.dart';
import 'package:hairsaloon/src/features/business_profile/domain/usecases/get_business_profile.dart';
import 'package:hairsaloon/src/features/business_profile/domain/usecases/save_business_profile.dart';
import 'package:hairsaloon/src/features/business_profile/presentation/state/business_profile_notifier.dart';
import 'package:hairsaloon/src/features/business_profile/presentation/state/business_profile_scope.dart';
import 'package:hairsaloon/src/features/dashboard/presentation/dashboard_shell.dart';
import 'package:hairsaloon/src/features/customers/presentation/customers_screen.dart';
import 'package:hairsaloon/src/features/employees/presentation/employee_agreement_screen.dart';
import 'package:hairsaloon/src/features/employees/presentation/employees_screen.dart';
import 'package:hairsaloon/src/features/expenses/presentation/expense_types_screen.dart';
import 'package:hairsaloon/src/features/finance/presentation/employee_earnings_screen.dart';
import 'package:hairsaloon/src/features/finance/presentation/finance_overview_screen.dart';
import 'package:hairsaloon/src/features/router/app_routes.dart';
import 'package:hairsaloon/src/features/services/presentation/new_service_screen.dart';
import 'package:hairsaloon/src/features/services/presentation/service_list_screen.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessCombApp extends StatefulWidget {
  const BusinessCombApp({super.key});

  @override
  State<BusinessCombApp> createState() => _BusinessCombAppState();
}

class _BusinessCombAppState extends State<BusinessCombApp> {
  late Future<_AppBootstrap> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppBootstrap>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingApp();
        }

        if (snapshot.hasError) {
          return _errorApp(snapshot.error);
        }

        final bootstrap = snapshot.data;
        if (bootstrap == null) {
          return _loadingApp(message: 'Loading local storage...');
        }

        return BusinessProfileScope(
          notifier: bootstrap.notifier,
          child: MaterialApp(
            title: 'Business COMB',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
              useMaterial3: true,
            ),
            initialRoute: bootstrap.hasSession
                ? AppRoutes.homeShell
                : AppRoutes.businessRegistration,
            routes: {
              AppRoutes.splash: (_) => const SplashScreen(),
              AppRoutes.login: (_) => const LoginScreen(),
              AppRoutes.businessRegistration: (_) =>
                  const BusinessRegistrationScreen(),
              AppRoutes.homeShell: (_) => const DashboardShell(),
              AppRoutes.appointments: (_) => const AppointmentsScreen(),
              AppRoutes.employees: (_) => const EmployeesScreen(),
              AppRoutes.employeeAgreement: (_) =>
                  const EmployeeAgreementScreen(),
              AppRoutes.serviceList: (_) => const ServiceListScreen(),
              AppRoutes.newService: (_) => const NewServiceScreen(),
              AppRoutes.financeOverview: (_) => const FinanceOverviewScreen(),
              AppRoutes.employeeEarnings: (_) => const EmployeeEarningsScreen(),
              AppRoutes.expenseTypes: (_) => const ExpenseTypesScreen(),
              AppRoutes.customers: (_) => const CustomersScreen(),
              AppRoutes.savedBills: (_) => const SavedBillsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == AppRoutes.billDetails) {
                final billId = settings.arguments as String?;
                if (billId == null) return null;
                return MaterialPageRoute(
                  builder: (_) => BillDetailsScreen(billId: billId),
                );
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _loadingApp({String message = 'Loading...'}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorApp(Object? error) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Failed to load local storage.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error?.toString() ?? 'Unknown error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _bootstrapFuture = _bootstrap();
                    });
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<_AppBootstrap> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final repository = SharedPrefsBusinessProfileRepository(prefs: prefs);
    final notifier = BusinessProfileNotifier(
      getBusinessProfile: GetBusinessProfile(repository),
      saveBusinessProfile: SaveBusinessProfile(repository),
      clearBusinessProfile: ClearBusinessProfile(repository),
    );
    await notifier.load();
    return _AppBootstrap(
      notifier: notifier,
      hasSession: notifier.profile != null,
    );
  }
}

class _AppBootstrap {
  const _AppBootstrap({
    required this.notifier,
    required this.hasSession,
  });

  final BusinessProfileNotifier notifier;
  final bool hasSession;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0), // from left
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // premium feel
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset('assets/logo.png', width: 140),

                const SizedBox(height: 20),

                // App Name
                const Text(
                  'BARBER SHOP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 10),

                // Animated blinking welcome text
                AnimatedBuilder(
                  animation: _blinkAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _blinkAnimation.value,
                      child: const Text(
                        'Welcome to Your Style ✂️',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Button
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
