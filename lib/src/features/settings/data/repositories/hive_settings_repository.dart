import 'package:hairsaloon/src/core/storage/hive_boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveSettingsRepository {
  HiveSettingsRepository({Box<dynamic>? box})
      : _box = box ?? Hive.box<dynamic>(HiveBoxes.settings);

  static const String taxRateKey = 'tax_rate';
  final Box<dynamic> _box;

  double getTaxRate() {
    final value = _box.get(taxRateKey);
    if (value is num) return value.toDouble();
    return 17.0;
  }

  Future<void> setTaxRate(double value) async {
    await _box.put(taxRateKey, value);
  }
}

