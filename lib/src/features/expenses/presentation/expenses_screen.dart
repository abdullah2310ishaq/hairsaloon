import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/expenses/data/local_expenses_store.dart';
import 'package:hairsaloon/src/features/expenses/domain/entities/expense_item.dart';
import 'package:hairsaloon/src/features/expenses/presentation/all_expenses_screen.dart';
import 'package:hairsaloon/src/features/expenses/presentation/expense_details_screen.dart';
import 'package:hairsaloon/src/features/expenses/presentation/expense_types_screen.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _statusFilter = 'Paid';

  List<ExpenseItem> get _items => LocalExpensesStore.items;

  List<ExpenseItem> get _filteredItems {
    return _items
        .where((item) => item.status == _statusFilter)
        .toList(growable: false);
  }

  double get _monthlyTotal => _items.fold(0, (sum, item) => sum + item.amount);

  double get _todayTotal {
    final now = DateTime.now();
    return _items
        .where(
          (item) =>
              item.date.year == now.year &&
              item.date.month == now.month &&
              item.date.day == now.day,
        )
        .fold(0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        children: [
          _buildHeaderWithTodayCard(context),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildFilters(),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  _statusFilter == 'Paid'
                      ? 'Paid Transactions'
                      : 'Unpaid Transactions',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AllExpensesScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            itemCount: _filteredItems.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _expenseTile(item),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithTodayCard(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    const overlapHeight = 86.0;
    const totalToTodayGap = 20.0;
    final yellowHeight = topInset + 220;

    return SizedBox(
      height: yellowHeight + overlapHeight + totalToTodayGap,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: yellowHeight,
            child: Container(
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(12, topInset + 6, 12, 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      // const Icon(CupertinoIcons.back, color: Colors.black),
                      // const SizedBox(width: 8),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Expenses',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Total Monthly Expenses',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rs.${_monthlyTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: yellowHeight - overlapHeight + totalToTodayGap,
            child: _buildTodayCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Today Expenses',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            'Rs.${_todayTotal.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final created = await Navigator.of(context).push<ExpenseItem>(
                  MaterialPageRoute(builder: (_) => const ExpenseTypesScreen()),
                );
                if (created == null) return;
                setState(() => LocalExpensesStore.add(created));
              },
              icon: const Icon(CupertinoIcons.add_circled, size: 14),
              label: const Text(
                'Add New Expense',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _filterChip('Paid'),
        const SizedBox(width: 8),
        _filterChip('Unpaid'),
      ],
    );
  }

  Widget _filterChip(String status) {
    final selected = _statusFilter == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _statusFilter = status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _expenseTile(ExpenseItem item) {
    final statusColor = item.status == 'Paid'
        ? const Color(0xFF2FAE4E)
        : const Color(0xFFE45A5A);
    final date =
        '${item.date.day.toString().padLeft(2, '0')}-'
        '${item.date.month.toString().padLeft(2, '0')}-${item.date.year}';
    final time =
        '${item.createdAt.hour.toString().padLeft(2, '0')}:'
        '${item.createdAt.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ExpenseDetailsScreen(item: item)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 84,
              child: Text(
                '$time\n$date',
                style: const TextStyle(fontSize: 10, color: Color(0xFF8D8D8D)),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.employeeName,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF2FAE4E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Text(
                        item.status,
                        style: TextStyle(fontSize: 10.5, color: statusColor),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${item.paymentType})',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF444444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description ?? 'No description',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Rs.${item.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete Expense'),
                    content: const Text(
                      'Are you sure you want to delete this expense?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (shouldDelete != true) return;
                setState(() => LocalExpensesStore.delete(item.id));
              },
              icon: const Icon(
                CupertinoIcons.delete,
                color: Color(0xFFE45A5A),
                size: 18,
              ),
              splashRadius: 16,
            ),
          ],
        ),
      ),
    );
  }
}
