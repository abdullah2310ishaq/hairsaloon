class LocalTaxRateStore {
  LocalTaxRateStore._();

  static double _taxRate = 17;

  static double get taxRate => _taxRate;

  static void setTaxRate(double value) {
    if (value < 0) return;
    _taxRate = value;
  }
}
