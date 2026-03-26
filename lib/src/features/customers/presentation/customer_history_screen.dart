import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/billing/domain/entities/bill.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class CustomerHistoryScreen extends StatelessWidget {
  const CustomerHistoryScreen({
    super.key,
    required this.customerLabel,
    required this.bills,
  });

  final String customerLabel;
  final List<Bill> bills;

  double get _totalSpent => bills.fold(0, (sum, bill) => sum + bill.grandTotal);

  @override
  Widget build(BuildContext context) {
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
          'Customer History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerLabel,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Visits: ${bills.length}  •  Total Billing: Rs.${_totalSpent.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...bills.map(_historyCard),
        ],
      ),
    );
  }

  Widget _historyCard(Bill bill) {
    final date = '${bill.createdAt.day.toString().padLeft(2, '0')}-'
        '${bill.createdAt.month.toString().padLeft(2, '0')}-${bill.createdAt.year}';

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
              Text(
                date,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B6B6B)),
              ),
              const Spacer(),
              Text(
                'Rs.${bill.grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...bill.lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      line.serviceName,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    'x${line.qty}',
                    style: const TextStyle(fontSize: 10.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rs.${line.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 14),
          Text(
            'Employee: ${bill.employeeName}  •  Payment: ${bill.paymentType}',
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF555555)),
          ),
        ],
      ),
    );
  }
}
