import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/billing/data/local_billing_store.dart';
import 'package:hairsaloon/src/features/employees/data/local_employees_store.dart';
import 'package:hairsaloon/src/features/employees/domain/entities/employee_item.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class EmployeeEarningsScreen extends StatelessWidget {
  const EmployeeEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employees = LocalEmployeesStore.employees;
    final bills = LocalBillingStore.bills;

    final rows = employees.map((employee) {
      final employeeSales = bills
          .where((bill) => bill.employeeName == employee.fullName)
          .fold<double>(0, (sum, bill) => sum + bill.grandTotal);
      final salary = _toDouble(employee.basicSalary);
      final commissionPercent = _toDouble(employee.commission);
      final commissionAmount = (employeeSales * commissionPercent) / 100;
      final totalPayout = salary + commissionAmount;
      return _EmployeeEarning(
        employee: employee,
        sales: employeeSales,
        salary: salary,
        commissionPercent: commissionPercent,
        commissionAmount: commissionAmount,
        totalPayout: totalPayout,
      );
    }).toList();

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
          'Employee Earnings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: rows.isEmpty
          ? const Center(child: Text('No employees found.'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: rows.map(_earningCard).toList(),
            ),
    );
  }

  static double _toDouble(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    final normalized = value.replaceAll(',', '').replaceAll('%', '').trim();
    return double.tryParse(normalized) ?? 0;
  }

  Widget _earningCard(_EmployeeEarning row) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.employee.fullName,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: row.employee.isActive ? const Color(0xFF46A758) : const Color(0xFFB0B0B0),
                  ),
                ),
                child: Text(
                  row.employee.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: row.employee.isActive ? const Color(0xFF2B7A3A) : const Color(0xFF6B6B6B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _line('Sales', 'Rs.${row.sales.toStringAsFixed(0)}'),
          _line('Basic Salary', 'Rs.${row.salary.toStringAsFixed(0)}'),
          _line('Commission %', '${row.commissionPercent.toStringAsFixed(0)}%'),
          _line('Commission Amount', 'Rs.${row.commissionAmount.toStringAsFixed(0)}'),
          const Divider(height: 14),
          _line(
            'Total Payout',
            'Rs.${row.totalPayout.toStringAsFixed(0)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeEarning {
  const _EmployeeEarning({
    required this.employee,
    required this.sales,
    required this.salary,
    required this.commissionPercent,
    required this.commissionAmount,
    required this.totalPayout,
  });

  final EmployeeItem employee;
  final double sales;
  final double salary;
  final double commissionPercent;
  final double commissionAmount;
  final double totalPayout;
}

