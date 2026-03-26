import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/billing/data/local_billing_store.dart';
import 'package:hairsaloon/src/features/billing/domain/entities/bill.dart';
import 'package:hairsaloon/src/features/router/app_routes.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _customerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final List<_ServiceCardData> _availableServices = const [
    _ServiceCardData(name: 'Haircut & Blow-dry', price: 1500, tag: "Men's Grooming"),
    _ServiceCardData(name: 'Skincare & Facials', price: 1500, tag: 'Skincare'),
    _ServiceCardData(name: 'Shave', price: 400, tag: "Men's Grooming"),
    _ServiceCardData(name: 'Haircut & Blow-dry', price: 2500, tag: 'Packages'),
  ];

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Billing',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.savedBills),
            icon: const Icon(CupertinoIcons.doc_text_search),
            color: Colors.black,
          ),
        ],
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
                const Text(
                  'Customer Info',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _customerNameCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: _fieldDecoration('Customer Name (optional)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneCtrl,
                  style: const TextStyle(fontSize: 13),
                  keyboardType: TextInputType.phone,
                  decoration: _fieldDecoration('Phone Number (optional)'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _proceedToBillingDetails,
                    child: const Text(
                      'Next',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            alignment: Alignment.centerLeft,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _TagChip(text: "Men's Grooming"),
                _TagChip(text: 'Skincare & Facials'),
                _TagChip(text: 'Hair'),
                _TagChip(text: 'Packages'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Available Services',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableServices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.25,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final service = _availableServices[index];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Rs.${service.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  void _proceedToBillingDetails() {
    final name = _customerNameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty && phone.isEmpty) {
      _showMessage('Enter customer name or phone number.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _BillingDetailsScreen(
          customerName: name,
          customerPhone: phone,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _BillingDetailsScreen extends StatefulWidget {
  const _BillingDetailsScreen({
    required this.customerName,
    required this.customerPhone,
  });

  final String customerName;
  final String customerPhone;

  @override
  State<_BillingDetailsScreen> createState() => _BillingDetailsScreenState();
}

class _BillingDetailsScreenState extends State<_BillingDetailsScreen> {
  final List<_ServiceCardData> _availableServices = const [
    _ServiceCardData(name: 'Haircut & Blow-dry', price: 1500, tag: "Men's Grooming"),
    _ServiceCardData(name: 'Skincare & Facials', price: 1500, tag: 'Skincare'),
    _ServiceCardData(name: 'Shave', price: 400, tag: "Men's Grooming"),
    _ServiceCardData(name: 'Haircut & Blow-dry', price: 2500, tag: 'Packages'),
  ];
  final Set<int> _selectedServiceIndexes = <int>{};
  late final Map<int, TextEditingController> _amountControllers;
  String _employee = 'Staff 1';
  String _paymentType = 'Cash';
  final double _taxPercent = 17;

  @override
  void initState() {
    super.initState();
    _amountControllers = {
      for (int i = 0; i < _availableServices.length; i++)
        i: TextEditingController(
          text: _availableServices[i].price.toStringAsFixed(0),
        ),
    };
  }

  @override
  void dispose() {
    for (final ctrl in _amountControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  List<BillLine> get _selectedLines => _selectedServiceIndexes
      .map((index) => _availableServices[index])
      .map(
        (s) {
          final i = _availableServices.indexOf(s);
          final typed = double.tryParse(_amountControllers[i]?.text ?? '');
          final effectivePrice = typed ?? s.price;
          return BillLine(
            serviceName: s.name,
            price: effectivePrice,
            qty: 1,
            tag: s.tag,
          );
        },
      )
      .toList();
  double get _subTotal => _selectedLines.fold(0, (sum, line) => sum + line.total);
  double get _taxAmount => (_subTotal * _taxPercent) / 100;
  double get _grandTotal => _subTotal + _taxAmount;

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
          'Create Bill',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Sub Total: ${_subTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tax: ${_taxPercent.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      'Total: Rs.${_grandTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.customerName.isEmpty
                        ? widget.customerPhone
                        : '${widget.customerName} • ${widget.customerPhone}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _employee,
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        decoration: _smallDecoration('Select Employee'),
                        items: const ['Staff 1', 'Staff 2']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _employee = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _paymentType,
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        decoration: _smallDecoration('Payment Type'),
                        items: const ['Cash']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _paymentType = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _saveBill,
                      child: const Text('Save', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _TagChip(text: "Men's Grooming"),
                _TagChip(text: 'Skincare & Facials'),
                _TagChip(text: 'Hair'),
                _TagChip(text: 'Packages'),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 6, 12, 8),
            child: Row(
              children: [
                Text(
                  'Available Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount: _availableServices.length * 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.86,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final i = index % _availableServices.length;
                final service = _availableServices[i];
                final selected = _selectedServiceIndexes.contains(i);
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedServiceIndexes.remove(i);
                      } else {
                        _selectedServiceIndexes.add(i);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.28)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppColors.primary : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          'Rs.${(double.tryParse(_amountControllers[i]?.text ?? '') ?? service.price).toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Service Amount List',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                ...List.generate(_availableServices.length, (i) {
                  final service = _availableServices[i];
                  final selected = _selectedServiceIndexes.contains(i);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Checkbox(
                          value: selected,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedServiceIndexes.add(i);
                              } else {
                                _selectedServiceIndexes.remove(i);
                              }
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            service.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 96,
                          child: TextField(
                            controller: _amountControllers[i],
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              prefixText: 'Rs.',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _smallDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _saveBill() {
    if (_selectedLines.isEmpty) {
      _showMessage('Select at least one service.');
      return;
    }
    final bill = Bill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      customerName: widget.customerName,
      customerPhone: widget.customerPhone,
      employeeName: _employee,
      paymentType: _paymentType,
      lines: _selectedLines,
      subTotal: _subTotal,
      taxPercent: _taxPercent,
      taxAmount: _taxAmount,
      grandTotal: _grandTotal,
    );
    LocalBillingStore.addBill(bill);
    _showMessage('Bill saved.');
    setState(() {
      _selectedServiceIndexes.clear();
    });
  }

  void _showMessage(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(text, style: const TextStyle(fontSize: 12)),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ServiceCardData {
  const _ServiceCardData({
    required this.name,
    required this.price,
    required this.tag,
  });

  final String name;
  final double price;
  final String tag;
}

