import 'package:flutter/foundation.dart';
import 'package:hairsaloon/src/features/settings/data/repositories/hive_settings_repository.dart';

class SettingsStore extends ChangeNotifier {
  SettingsStore({required HiveSettingsRepository repository})
      : _repository = repository,
        _taxRate = repository.getTaxRate();

  final HiveSettingsRepository _repository;

  double _taxRate;
  double get taxRate => _taxRate;

  Future<void> setTaxRate(double value) async {
    if (value < 0 || value == _taxRate) return;
    await _repository.setTaxRate(value);
    _taxRate = value;
    notifyListeners();
  }
}

