import 'package:hairsaloon/src/features/billing/domain/entities/bill.dart';

class LocalBillingStore {
  LocalBillingStore._();

  static final List<Bill> _bills = <Bill>[];

  static List<Bill> get bills => List<Bill>.unmodifiable(_bills);

  static void addBill(Bill bill) {
    _bills.insert(0, bill);
  }

  static Bill? getById(String id) {
    for (final bill in _bills) {
      if (bill.id == id) return bill;
    }
    return null;
  }
}

