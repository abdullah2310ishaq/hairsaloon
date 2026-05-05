import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/core/storage/hive_boxes.dart';
import 'package:hairsaloon/src/features/billing/domain/entities/bill.dart';
import 'package:hairsaloon/src/features/billing/presentation/state/billing_store.dart';
import 'package:hairsaloon/src/features/employees/domain/entities/employee_item.dart';
import 'package:hairsaloon/src/features/expenses/presentation/state/expenses_store.dart';
import 'package:hairsaloon/src/features/finance/domain/entities/finance_period.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class EmployeeIncomeDetailScreen extends StatelessWidget {
  const EmployeeIncomeDetailScreen({
    super.key,
    required this.employee,
    required this.period,
    required this.anchorDate,
  });

  final EmployeeItem employee;
  final FinancePeriod period;
  final DateTime anchorDate;

  @override
  Widget build(BuildContext context) {
    final employeeName = employee.fullName.trim().toLowerCase();
    final commissionPercent = _toDouble(employee.commission);
    final bills = context
        .watch<BillingStore>()
        .bills
        .where((bill) => bill.employeeName == employee.fullName)
        .where((bill) => _isInPeriod(bill.createdAt, anchorDate, period))
        .toList(growable: false);
    final expenses = context
        .watch<ExpensesStore>()
        .items
        .where(
          (item) =>
              item.employeeName.trim().toLowerCase() == employeeName &&
              item.status.trim().toLowerCase() == 'unpaid',
        )
        .where((item) => _isInPeriod(item.date, anchorDate, period))
        .toList(growable: false);
    final dailyRows = _buildDailyRows(bills, commissionPercent);

    final totalSales = bills.fold<double>(0, (sum, bill) => sum + bill.grandTotal);
    final totalEarning = (totalSales * commissionPercent) / 100;
    final totalCashSales = bills
        .where((b) => b.paymentType.trim().toLowerCase() == 'cash')
        .fold<double>(0, (sum, b) => sum + b.grandTotal);
    final totalPaid = (totalCashSales * commissionPercent) / 100;
    final totalCommissionDue = totalEarning - totalPaid;

    final totalDue = expenses.fold<double>(
      0.0,
      (sum, item) => sum + item.amount,
    );
    final safeDue = totalDue < 0 ? 0.0 : totalDue;
    final netDue = (totalCommissionDue - safeDue);
    final safeNetDue = netDue < 0 ? 0.0 : netDue;

    final payoutBox = Hive.box<Map>(HiveBoxes.employeePayouts);
    final payoutKey = _payoutKey(employee.id, period, anchorDate);
    final settledRaw = payoutBox.get(payoutKey);
    final isSettled = settledRaw != null;
    final settledAt = isSettled
        ? DateTime.tryParse((settledRaw['createdAt'] as String?) ?? '')
        : null;
    final settledAmount = isSettled ? (settledRaw['amount'] as num?)?.toDouble() ?? 0.0 : 0.0;
    final dueAfterSettlement = isSettled ? 0.0 : safeNetDue;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _TopSection(
              employee: employee,
              bills: bills,
              totalEarning: totalEarning,
              totalDue: safeDue,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _dueAmountCard(
                dueAfterSettlement,
                subtitle: _settlementSubtitle(isSettled, settledAt, settledAmount),
                onSettleUp: (dueAfterSettlement <= 0)
                    ? null
                    : () => _settleUpPayout(
                          context: context,
                          payoutKey: payoutKey,
                          employeeId: employee.id,
                          employeeName: employee.fullName,
                          period: period,
                          anchorDate: anchorDate,
                          amount: dueAfterSettlement,
                        ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Text(
                _dailyTitle(period),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
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
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Text(
                'Bills',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          if (bills.isEmpty)
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
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _BillTile(bill: bill),
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
            dueAmount: dueAmount < 0 ? 0.0 : dueAmount,
          );
        })
        .toList(growable: false);

    rows.sort((a, b) => b.date.compareTo(a.date));
    return rows;
  }

  static String _dailyTitle(FinancePeriod period) {
    switch (period) {
      case FinancePeriod.daily:
        return 'Daily Income';
      case FinancePeriod.weekly:
        return 'Weekly Income (day-wise)';
      case FinancePeriod.monthly:
        return 'Monthly Income (day-wise)';
    }
  }

  static bool _isInPeriod(DateTime date, DateTime anchor, FinancePeriod period) {
    final target = DateTime(date.year, date.month, date.day);
    switch (period) {
      case FinancePeriod.daily:
        return target == DateTime(anchor.year, anchor.month, anchor.day);
      case FinancePeriod.weekly:
        final start = DateTime(anchor.year, anchor.month, anchor.day)
            .subtract(Duration(days: anchor.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return !target.isBefore(start) && !target.isAfter(end);
      case FinancePeriod.monthly:
        return target.year == anchor.year && target.month == anchor.month;
    }
  }

  static String _payoutKey(String employeeId, FinancePeriod period, DateTime anchor) {
    final day = DateTime(anchor.year, anchor.month, anchor.day);
    switch (period) {
      case FinancePeriod.daily:
        return 'payout:$employeeId:daily:${day.toIso8601String()}';
      case FinancePeriod.weekly:
        final start = day.subtract(Duration(days: day.weekday - 1));
        return 'payout:$employeeId:weekly:${start.toIso8601String()}';
      case FinancePeriod.monthly:
        final month = DateTime(anchor.year, anchor.month, 1);
        return 'payout:$employeeId:monthly:${month.toIso8601String()}';
    }
  }

  static String? _settlementSubtitle(bool isSettled, DateTime? settledAt, double amount) {
    if (!isSettled) return null;
    final when = settledAt == null ? '—' : _formatDate(settledAt);
    return 'Settled: ${_formatCurrency(amount)} on $when';
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
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
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
                              fontSize: 26,
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
          bottom: -48,
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
                  fontSize: 30,
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

Widget _dueAmountCard(
  double dueAmount, {
  String? subtitle,
  VoidCallback? onSettleUp,
}) {
  final safeDue = dueAmount < 0 ? 0.0 : dueAmount;
  final isSettled = safeDue <= 0;
  return Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(
          CupertinoIcons.money_dollar_circle,
          color: AppColors.danger,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Due Amount',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatCurrency(safeDue),
                style: const TextStyle(
                  color: AppColors.danger,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(
          height: 34,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isSettled ? const Color(0xFFC5C5C5) : AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            onPressed: isSettled ? null : onSettleUp,
            child: const Text('Settle Up'),
          ),
        ),
      ],
    ),
  );
}

Future<void> _settleUpPayout({
  required BuildContext context,
  required String payoutKey,
  required String employeeId,
  required String employeeName,
  required FinancePeriod period,
  required DateTime anchorDate,
  required double amount,
}) async {
  final safeAmount = amount < 0 ? 0.0 : amount;
  if (safeAmount <= 0) return;

  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      title: const Text(
        'Settle Up',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
      ),
      content: Text(
        'Mark ${employeeName.trim()} payout as settled?\n\nAmount: ${_formatCurrency(safeAmount)}',
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(foregroundColor: Colors.black87),
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Settle', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );
  if (confirm != true) return;

  final box = Hive.box<Map>(HiveBoxes.employeePayouts);
  await box.put(payoutKey, <String, dynamic>{
    'id': payoutKey,
    'employeeId': employeeId,
    'employeeName': employeeName.trim(),
    'period': period.name,
    'anchorDate': DateTime(anchorDate.year, anchorDate.month, anchorDate.day).toIso8601String(),
    'amount': safeAmount,
    'createdAt': DateTime.now().toIso8601String(),
  });
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
      margin: const EdgeInsets.symmetric(horizontal: 12),
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

class _BillTile extends StatelessWidget {
  const _BillTile({required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final customerLabel = bill.customerName.trim().isNotEmpty
        ? bill.customerName.trim()
        : (bill.customerPhone.trim().isNotEmpty
            ? bill.customerPhone.trim()
            : 'Walk-in Customer');
    final dateText =
        '${bill.createdAt.day.toString().padLeft(2, '0')}-${bill.createdAt.month.toString().padLeft(2, '0')}-${bill.createdAt.year}';
    final timeText =
        '${bill.createdAt.hour.toString().padLeft(2, '0')}:${bill.createdAt.minute.toString().padLeft(2, '0')}';
    final firstService =
        bill.lines.isNotEmpty ? bill.lines.first.serviceName : 'No service';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(
              '$timeText\n$dateText',
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${bill.paymentType}  •  $firstService',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatCurrency(bill.grandTotal),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
