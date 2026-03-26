import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/expenses/data/local_expenses_store.dart';
import 'package:hairsaloon/src/features/expenses/domain/entities/expense_item.dart';
import 'package:hairsaloon/src/features/expenses/presentation/expense_types_screen.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _statusFilter = 'All';

  List<ExpenseItem> get _items => LocalExpensesStore.items;

  List<ExpenseItem> get _filteredItems {
    if (_statusFilter == 'All') return _items;
    return _items.where((item) => item.status == _statusFilter).toList(growable: false);
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: [
                  _buildTodayCard(context),
                  const SizedBox(height: 10),
                  _buildFilters(),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setState(() => _statusFilter = 'All'),
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
                  ListView.builder(
                    itemCount: _filteredItems.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _expenseTile(item);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 86),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.back, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Expances',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Column(
                children: const [
                  Icon(CupertinoIcons.settings_solid, color: Colors.black, size: 22),
                  SizedBox(height: 2),
                  Text('Settings', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Total Monthly Expances',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            'Rs.${_monthlyTotal.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -70),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text('Today Expances', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  'Add New Expance',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Transform.translate(
      offset: const Offset(0, -64),
      child: Row(
        children: [
          _filterChip('Paid'),
          const SizedBox(width: 8),
          _filterChip('Unpaid'),
        ],
      ),
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
    final statusColor = item.status == 'Paid' ? const Color(0xFF2FAE4E) : const Color(0xFFE45A5A);
    final date = '${item.date.day.toString().padLeft(2, '0')}-'
        '${item.date.month.toString().padLeft(2, '0')}-${item.date.year}';
    final time = '${item.createdAt.hour.toString().padLeft(2, '0')}:'
        '${item.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
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
                    Text(item.status, style: TextStyle(fontSize: 10.5, color: statusColor)),
                    const SizedBox(width: 4),
                    Text(
                      '(${item.paymentType})',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF444444)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.description ?? 'No description',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
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
            onPressed: () => setState(() => LocalExpensesStore.delete(item.id)),
            icon: const Icon(CupertinoIcons.delete, color: Color(0xFFE45A5A), size: 18),
            splashRadius: 16,
          ),
        ],
      ),
    );
  }
}

