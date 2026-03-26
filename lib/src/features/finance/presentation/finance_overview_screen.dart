import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/billing/data/local_billing_store.dart';
import 'package:hairsaloon/src/features/employees/domain/entities/employee_item.dart';
import 'package:hairsaloon/src/features/employees/data/local_employees_store.dart';
import 'package:hairsaloon/src/features/expenses/data/local_expenses_store.dart';
import 'package:hairsaloon/src/features/router/app_routes.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class FinanceOverviewScreen extends StatelessWidget {
  const FinanceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bills = LocalBillingStore.bills;
    final expenses = LocalExpensesStore.items;
    final employees = LocalEmployeesStore.employees;

    final totalRevenue = bills.fold<double>(0, (sum, b) => sum + b.grandTotal);
    final thisMonthRevenue = bills
        .where((b) => b.createdAt.year == now.year && b.createdAt.month == now.month)
        .fold<double>(0, (sum, b) => sum + b.grandTotal);
    final todayRevenue = bills
        .where(
          (b) =>
              b.createdAt.year == now.year &&
              b.createdAt.month == now.month &&
              b.createdAt.day == now.day,
        )
        .fold<double>(0, (sum, b) => sum + b.grandTotal);

    final paidExpenses = expenses
        .where((e) => e.status == 'Paid')
        .fold<double>(0, (sum, e) => sum + e.amount);
    final unpaidExpenses = expenses
        .where((e) => e.status == 'Unpaid')
        .fold<double>(0, (sum, e) => sum + e.amount);
    final thisMonthPaidExpenses = expenses
        .where(
          (e) =>
              e.status == 'Paid' && e.date.year == now.year && e.date.month == now.month,
        )
        .fold<double>(0, (sum, e) => sum + e.amount);

    final netProfit = totalRevenue - paidExpenses;
    final activeEmployees = employees.where((e) => e.isActive).length;
    final salaryCommitment = employees.fold<double>(
      0,
      (sum, e) => sum + _toDouble(e.basicSalary),
    );
    final estimatedCommission = bills.fold<double>(0, (sum, bill) {
      final employee = _findEmployeeByName(employees, bill.employeeName);
      final percent = _toDouble(employee?.commission);
      return sum + ((bill.grandTotal * percent) / 100);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
        ),
        title: const Text(
          'Finance Overview',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _summaryCard(
            title: 'Net Profit',
            value: 'Rs.${netProfit.toStringAsFixed(0)}',
            subtitle:
                'Revenue Rs.${totalRevenue.toStringAsFixed(0)} • Paid Expenses Rs.${paidExpenses.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _smallMetricCard(
                  label: 'Today Sales',
                  value: 'Rs.${todayRevenue.toStringAsFixed(0)}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _smallMetricCard(
                  label: 'This Month Sales',
                  value: 'Rs.${thisMonthRevenue.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _smallMetricCard(
                  label: 'Paid Expenses',
                  value: 'Rs.${paidExpenses.toStringAsFixed(0)}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _smallMetricCard(
                  label: 'Unpaid Expenses',
                  value: 'Rs.${unpaidExpenses.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _smallMetricCard(
                  label: 'Active Employees',
                  value: activeEmployees.toString(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _smallMetricCard(
                  label: 'Monthly Salaries',
                  value: 'Rs.${salaryCommitment.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _summaryCard(
            title: 'Team Cost Insight',
            value: 'Rs.${(salaryCommitment + estimatedCommission).toStringAsFixed(0)}',
            subtitle:
                'Salaries Rs.${salaryCommitment.toStringAsFixed(0)} • Estimated Commission Rs.${estimatedCommission.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 10),
          _summaryCard(
            title: 'This Month Health',
            value: 'Rs.${(thisMonthRevenue - thisMonthPaidExpenses).toStringAsFixed(0)}',
            subtitle:
                'Month Revenue Rs.${thisMonthRevenue.toStringAsFixed(0)} • Month Paid Expenses Rs.${thisMonthPaidExpenses.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 10),
          _actionTile(
            title: 'Employee Earnings',
            subtitle: 'Salary + commission details with real sales',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.employeeEarnings),
          ),
          const SizedBox(height: 8),
          _actionTile(
            title: 'Saved Bills',
            subtitle: 'View all generated bills and totals',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.savedBills),
          ),
          const SizedBox(height: 8),
          _actionTile(
            title: 'Customers Finance History',
            subtitle: 'Customer wise billing history and totals',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.customers),
          ),
        ],
      ),
    );
  }

  static double _toDouble(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    final normalized = value.replaceAll(',', '').replaceAll('%', '').trim();
    return double.tryParse(normalized) ?? 0;
  }

  static EmployeeItem? _findEmployeeByName(List<EmployeeItem> employees, String name) {
    for (final employee in employees) {
      if (employee.fullName == name) return employee;
    }
    return null;
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _smallMetricCard({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _actionTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        title: Text(
          title,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 10.5),
        ),
        trailing: const Icon(CupertinoIcons.chevron_right, size: 15),
      ),
    );
  }
}

