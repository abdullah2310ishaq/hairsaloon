import 'package:hairsaloon/src/core/storage/hive_boxes.dart';
import 'package:hairsaloon/src/features/billing/domain/entities/bill.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveBillingRepository {
  HiveBillingRepository({
    Box<Map>? billsBox,
    Box<String>? phonesBox,
  })  : _billsBox = billsBox ?? Hive.box<Map>(HiveBoxes.bills),
        _phonesBox = phonesBox ?? Hive.box<String>(HiveBoxes.customerPhones);

  final Box<Map> _billsBox;
  final Box<String> _phonesBox;

  List<Bill> getBills() {
    final values = _billsBox.values
        .map((item) => Bill.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    values.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return values;
  }

  Bill? getById(String id) {
    final raw = _billsBox.get(id);
    if (raw == null) return null;
    return Bill.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> saveBill(Bill bill) async {
    await _billsBox.put(bill.id, bill.toJson());
    await addKnownCustomerPhone(bill.customerPhone);
  }

  List<String> getCustomerPhones() {
    return _phonesBox.values.toList(growable: false);
  }

  Future<bool> addKnownCustomerPhone(String phone) async {
    final normalized = _normalizePhone(phone);
    if (normalized.isEmpty) return false;
    final exists = _phonesBox.containsKey(normalized);
    if (exists) return false;
    await _phonesBox.put(normalized, phone.trim());
    return true;
  }

  bool hasKnownCustomerPhone(String phone) {
    final normalized = _normalizePhone(phone);
    if (normalized.isEmpty) return false;
    return _phonesBox.containsKey(normalized);
  }

  List<String> searchCustomerPhones(String query) {
    final normalized = _normalizePhone(query);
    if (normalized.isEmpty) return const <String>[];
    return _phonesBox.values
        .where((phone) => _normalizePhone(phone).contains(normalized))
        .toList(growable: false);
  }

  static String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9+]'), '');
  }
}

