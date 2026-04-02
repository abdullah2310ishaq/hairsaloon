import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/billing/data/local_billing_store.dart';
import 'package:hairsaloon/src/features/billing/domain/entities/bill.dart';
import 'package:hairsaloon/src/features/employees/domain/entities/employee_item.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class EmployeeIncomeDetailScreen extends StatelessWidget {
  const EmployeeIncomeDetailScreen({super.key, required this.employee});

  final EmployeeItem employee;

  @override
  Widget build(BuildContext context) {
    final bills = LocalBillingStore.bills
        .where((bill) => bill.employeeName == employee.fullName)
        .toList(growable: false);
    final dailyRows = _buildDailyRows(bills, _toDouble(employee.commission));

    final totalEarning = dailyRows.fold<double>(
      0,
      (sum, row) => sum + row.earningAmount,
    );
    final totalDue = dailyRows.fold<double>(
      0,
      (sum, row) => sum + row.dueAmount,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _TopSection(
              employee: employee,
              bills: bills,
              totalEarning: totalEarning,
              totalDue: totalDue,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Text(
                'Daily Income',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (dailyRows.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: _EmptyStateCard(),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              sliver: SliverList.builder(
                itemCount: dailyRows.length,
                itemBuilder: (context, index) {
                  final row = dailyRows[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _DailyIncomeTile(row: row),
                  );
                },
              ),
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

  static List<_DailyIncomeRow> _buildDailyRows(
    List<Bill> bills,
    double commissionPercent,
  ) {
    final grouped = <DateTime, _DailyAccumulator>{};

    for (final bill in bills) {
      final date = DateTime(
        bill.createdAt.year,
        bill.createdAt.month,
        bill.createdAt.day,
      );
      final state = grouped.putIfAbsent(date, _DailyAccumulator.new);
      state.totalSales += bill.grandTotal;
      if (bill.paymentType.trim().toLowerCase() == 'cash') {
        state.cashSales += bill.grandTotal;
      }
    }

    final rows = grouped.entries
        .map((entry) {
          final earningAmount =
              (entry.value.totalSales * commissionPercent) / 100;
          final paidAmount = (entry.value.cashSales * commissionPercent) / 100;
          final dueAmount = earningAmount - paidAmount;
          return _DailyIncomeRow(
            date: entry.key,
            earningAmount: earningAmount,
            paidAmount: paidAmount,
            dueAmount: dueAmount < 0 ? 0 : dueAmount,
          );
        })
        .toList(growable: false);

    rows.sort((a, b) => b.date.compareTo(a.date));
    return rows;
  }
}

class _TopSection extends StatelessWidget {
  const _TopSection({
    required this.employee,
    required this.bills,
    required this.totalEarning,
    required this.totalDue,
  });

  final EmployeeItem employee;
  final List<Bill> bills;
  final double totalEarning;
  final double totalDue;

  @override
  Widget build(BuildContext context) {
    final joiningDate = _joiningDateText(bills);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 74),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      CupertinoIcons.back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.surface,
                      child: Text(
                        _initials(employee.fullName),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (employee.speciality?.trim().isNotEmpty ?? false)
                                ? employee.speciality!.trim()
                                : 'Employee',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            employee.fullName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            joiningDate,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: -44,
          child: _totalEarningCard(totalEarning),
        ),
      ],
    );
  }

  String _joiningDateText(List<Bill> bills) {
    if (bills.isEmpty) return 'Joining : --';
    var earliest = bills.first.createdAt;
    for (final bill in bills.skip(1)) {
      if (bill.createdAt.isBefore(earliest)) {
        earliest = bill.createdAt;
      }
    }
    return 'Joining : ${_formatDate(earliest)}';
  }

  static Widget _totalEarningCard(double totalEarning) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.success.withOpacity(0.1),
            ),
            child: const Icon(
              CupertinoIcons.money_dollar_circle,
              color: AppColors.success,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Earning',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCurrency(totalEarning),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyIncomeTile extends StatelessWidget {
  const _DailyIncomeTile({required this.row});

  final _DailyIncomeRow row;

  @override
  Widget build(BuildContext context) {
    final isSettled = row.dueAmount <= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _amountColumn(
            label: 'Earning',
            value: _formatCurrency(row.earningAmount),
            valueColor: AppColors.textPrimary,
          ),
          _thinDivider(),
          _amountColumn(
            label: 'Paid Amount',
            value: _formatCurrency(row.paidAmount),
            valueColor: AppColors.success,
          ),
          _thinDivider(),
          _amountColumn(
            label: 'Due Amount',
            value: _formatCurrency(row.dueAmount),
            valueColor: AppColors.danger,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 30,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: isSettled
                        ? const Color(0xFFC5C5C5)
                        : AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: isSettled
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Settlement flow can be connected here.',
                              ),
                            ),
                          );
                        },
                  child: const Text('Settle Up'),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(row.date),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountColumn({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _thinDivider() {
    return Container(
      width: 1,
      height: 30,
      color: const Color(0xFFE2E2E2),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'No daily income records available for this employee.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DailyAccumulator {
  double totalSales = 0;
  double cashSales = 0;
}

class _DailyIncomeRow {
  const _DailyIncomeRow({
    required this.date,
    required this.earningAmount,
    required this.paidAmount,
    required this.dueAmount,
  });

  final DateTime date;
  final double earningAmount;
  final double paidAmount;
  final double dueAmount;
}

String _formatCurrency(double value) {
  final absolute = value.abs().toStringAsFixed(1);
  final parts = absolute.split('.');
  final whole = parts.first;
  final fraction = parts.last;
  final withCommas = whole.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final sign = value < 0 ? '-' : '';
  return 'Rs.$sign$withCommas.$fraction';
}

String _formatDate(DateTime date) {
  const months = <String>[
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final first = parts.first;
    return first.isEmpty ? '?' : first.substring(0, 1).toUpperCase();
  }
  final first = parts.first.isNotEmpty ? parts.first.substring(0, 1) : '';
  final second = parts.last.isNotEmpty ? parts.last.substring(0, 1) : '';
  return '$first$second'.toUpperCase();
}
