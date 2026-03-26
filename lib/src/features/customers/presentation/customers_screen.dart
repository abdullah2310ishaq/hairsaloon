import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/billing/data/local_billing_store.dart';
import 'package:hairsaloon/src/features/billing/domain/entities/bill.dart';
import 'package:hairsaloon/src/features/customers/presentation/customer_history_screen.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  Map<String, List<Bill>> get _groupedCustomers {
    final grouped = <String, List<Bill>>{};
    for (final bill in LocalBillingStore.bills) {
      final name = bill.customerName.trim();
      final phone = bill.customerPhone.trim();
      final key = name.isNotEmpty
          ? (phone.isNotEmpty ? '$name • $phone' : name)
          : (phone.isNotEmpty ? phone : 'Walk-in Customer');
      grouped.putIfAbsent(key, () => <Bill>[]).add(bill);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final customers = _groupedCustomers.entries.toList()
      ..sort((a, b) => b.value.first.createdAt.compareTo(a.value.first.createdAt));

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
          'Customers',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: customers.isEmpty
          ? const Center(
              child: Text(
                'No customer history yet.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final entry = customers[index];
                final bills = entry.value;
                final lastBill = bills.first;
                final totalSpent = bills.fold<double>(0, (sum, bill) => sum + bill.grandTotal);

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CustomerHistoryScreen(
                          customerLabel: entry.key,
                          bills: bills,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
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
                              Text(
                                entry.key,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Visits: ${bills.length}  •  Last: ${_formatDate(lastBill.createdAt)}',
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF666666)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Total Billing: Rs.${totalSpent.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.black54),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}

