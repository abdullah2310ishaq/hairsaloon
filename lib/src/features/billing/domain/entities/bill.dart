class BillLine {
  const BillLine({
    required this.serviceName,
    required this.price,
    this.qty = 1,
    this.tag = '',
  });

  final String serviceName;
  final int qty;
  final double price;
  final String tag;

  double get total => qty * price;
}

class Bill {
  const Bill({
    required this.id,
    required this.createdAt,
    required this.customerName,
    required this.customerPhone,
    required this.employeeName,
    required this.paymentType,
    required this.lines,
    required this.subTotal,
    required this.taxPercent,
    required this.taxAmount,
    required this.grandTotal,
  });

  final String id;
  final DateTime createdAt;
  final String customerName;
  final String customerPhone;
  final String employeeName;
  final String paymentType;
  final List<BillLine> lines;
  final double subTotal;
  final double taxPercent;
  final double taxAmount;
  final double grandTotal;
}

