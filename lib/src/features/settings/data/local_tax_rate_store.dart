import 'package:flutter/foundation.dart';

@Deprecated('Use SettingsStore + HiveSettingsRepository instead.')
class LocalTaxRateStore {
  LocalTaxRateStore._();

  static double _taxRate = 17;
  static final ValueNotifier<double> _taxRateNotifier = ValueNotifier<double>(
    _taxRate,
  );

  static double get taxRate => _taxRate;
  static ValueListenable<double> get taxRateListenable => _taxRateNotifier;

  static void setTaxRate(double value) {
    if (value < 0) return;
    if (_taxRate == value) return;
    _taxRate = value;
    _taxRateNotifier.value = value;
  }
}
