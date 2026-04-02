import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/billing/data/local_billing_store.dart';
import 'package:hairsaloon/src/features/billing/domain/entities/bill.dart';
import 'package:hairsaloon/src/features/employees/data/local_employees_store.dart';
import 'package:hairsaloon/src/features/router/app_routes.dart';
import 'package:hairsaloon/src/features/services/data/local_services_store.dart';
import 'package:hairsaloon/src/features/services/domain/entities/service_item.dart';
import 'package:hairsaloon/src/features/settings/data/local_tax_rate_store.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _phoneCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _servicesSectionKey = GlobalKey();
  bool _hidePhoneSuggestions = false;
  String _selectedCategory = 'All';
  final Set<String> _selectedServiceIds = <String>{};
  final Map<String, double> _servicePricesById = <String, double>{};
  late String _employee;
  String _paymentType = 'Cash';

  List<ServiceItem> get _services => LocalServicesStore.services;
  List<String> get _categories {
    final values = _services.map((service) => service.category).toSet().toList()
      ..sort();
    return <String>['All', ...values];
  }

  List<ServiceItem> get _filteredServices {
    if (_selectedCategory == 'All') return _services;
    return _services.where((s) => s.category == _selectedCategory).toList();
  }

  List<BillLine> get _selectedLines {
    final selectedServices = _services
        .where((s) => _selectedServiceIds.contains(s.id))
        .toList(growable: false);
    return selectedServices
        .map((service) {
          final amount = _servicePricesById[service.id] ?? service.price;
          return BillLine(
            serviceName: service.subcategory,
            price: amount,
            qty: 1,
            tag: service.category,
          );
        })
        .toList(growable: false);
  }

  double get _subTotal =>
      _selectedLines.fold(0, (sum, line) => sum + line.total);
  double get _taxPercent => LocalTaxRateStore.taxRate;
  double get _taxAmount => (_subTotal * _taxPercent) / 100;
  double get _grandTotal => _subTotal + _taxAmount;

  @override
  void initState() {
    super.initState();
    final activeEmployees = LocalEmployeesStore.employees
        .where((e) => e.isActive)
        .map((e) => e.fullName)
        .where((name) => name.isNotEmpty)
        .toList();
    _employee = activeEmployees.isNotEmpty
        ? activeEmployees.first
        : 'Unassigned';
    for (final service in _services) {
      _servicePricesById[service.id] = service.price;
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeOptions = LocalEmployeesStore.employees
        .where((e) => e.isActive)
        .map((e) => e.fullName)
        .where((name) => name.isNotEmpty)
        .toList();
    if (employeeOptions.isEmpty) employeeOptions.add('Unassigned');
    if (!employeeOptions.contains(_employee)) _employee = employeeOptions.first;
    final customerPhone = _phoneCtrl.text.trim();
    final phoneMatches = _phoneMatches(customerPhone);
    final showPhoneMatches =
        !_hidePhoneSuggestions &&
        customerPhone.isNotEmpty &&
        phoneMatches.isNotEmpty;
    final hasCustomerInfo = customerPhone.isNotEmpty;
    final customerInfoText = 'Customer Phone: $customerPhone';

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
          'Billing',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        controller: _scrollCtrl,
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.cart,
                      size: 22,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_selectedServiceIds.length.toString().padLeft(2, '0')} services used',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 30,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.savedBills),
                        child: const Text(
                          'Saved Bills',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Sub Total : ${_subTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tax : ${_taxPercent.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total : Rs.${_grandTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        style: const TextStyle(fontSize: 12),
                        keyboardType: TextInputType.phone,
                        onChanged: (_) {
                          if (!mounted) return;
                          setState(() => _hidePhoneSuggestions = false);
                        },
                        onSubmitted: (value) {
                          if (value.trim().isEmpty) return;
                          if (_hasKnownPhone(value)) return;
                          _showMessage('Phone number does not exist. Tap Add New.');
                        },
                        decoration: _smallDecoration(
                          'Enter Customer Phone Number',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          _addCurrentPhoneAsNew();
                        },
                        child: const Text(
                          'Add New',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
                if (showPhoneMatches) ...[
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: phoneMatches
                          .take(4)
                          .map(
                            (customer) => InkWell(
                              onTap: () {
                                setState(() {
                                  _phoneCtrl.text = customer.phone;
                                  _hidePhoneSuggestions = true;
                                });
                                FocusScope.of(context).unfocus();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.search,
                                      size: 14,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        customer.phone,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ],
                if (hasCustomerInfo) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      customerInfoText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _employee,
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        iconSize: 16,
                        decoration: _smallDecoration('Employee'),
                        selectedItemBuilder: (context) => employeeOptions
                            .map(
                              (name) => Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            )
                            .toList(),
                        items: employeeOptions
                            .map(
                              (name) => DropdownMenuItem(
                                value: name,
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _employee = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _paymentType,
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        iconSize: 16,
                        decoration: _smallDecoration('Payment'),
                        selectedItemBuilder: (context) =>
                            const ['Cash', 'Card', 'Online']
                                .map(
                                  (type) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      type,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                )
                                .toList(),
                        items: const ['Cash', 'Card', 'Online']
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _paymentType = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 96,
                      height: 44,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _saveBill,
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Save Bill',
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final category = _categories[i];
                final selected = _selectedCategory == category;
                return _TagChip(
                  text: category,
                  selected: selected,
                  onTap: () => setState(() => _selectedCategory = category),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            key: _servicesSectionKey,
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: const Text(
              'Available Services',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredServices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final service = _filteredServices[index];
              final selected = _selectedServiceIds.contains(service.id);
              final price = _servicePricesById[service.id] ?? service.price;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedServiceIds.remove(service.id);
                    } else {
                      _selectedServiceIds.add(service.id);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? Colors.black
                          : Colors.grey.withValues(alpha: 0.2),
                      width: selected ? 1.8 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: const Alignment(0, 0.3),
                          child: Text(
                            service.subcategory,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Transform.translate(
                        offset: const Offset(0, -2),
                        child: Text(
                          'Rs.${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(height: 6),
                        const Icon(
                          CupertinoIcons.checkmark_circle_fill,
                          size: 15,
                          color: Colors.black,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _smallDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _addCurrentPhoneAsNew() {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _showMessage('Enter customer phone number first.');
      return;
    }
    final added = LocalBillingStore.addKnownCustomerPhone(phone);
    setState(() {
      _hidePhoneSuggestions = true;
    });
    if (added) {
      _showMessage('New customer number added.');
    } else {
      _showMessage('Customer number already exists.');
    }
    _scrollToServices();
  }

  void _saveBill() {
    if (_selectedLines.isEmpty) {
      _showMessage('Select at least one service.');
      return;
    }
    final phone = _phoneCtrl.text.trim();
    if (phone.isNotEmpty && !_hasKnownPhone(phone)) {
      _showMessage('Number not found. Select suggestion or tap Add New.');
      return;
    }
    final bill = Bill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      customerName: '',
      customerPhone: phone,
      employeeName: _employee,
      paymentType: _paymentType,
      lines: _selectedLines,
      subTotal: _subTotal,
      taxPercent: _taxPercent,
      taxAmount: _taxAmount,
      grandTotal: _grandTotal,
    );
    LocalBillingStore.addBill(bill);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bill saved successfully'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.billDetails, arguments: bill.id).then((_) {
      if (!mounted) return;
      _resetForNewBill();
    });
  }

  List<_PhoneMatch> _phoneMatches(String query) {
    final matches = LocalBillingStore.searchCustomerPhones(query);
    return matches
        .map((phone) => _PhoneMatch(phone: phone))
        .toList(growable: false);
  }

  bool _hasKnownPhone(String value) {
    return LocalBillingStore.hasKnownCustomerPhone(value);
  }

  void _resetForNewBill() {
    final activeEmployees = LocalEmployeesStore.employees
        .where((e) => e.isActive)
        .map((e) => e.fullName)
        .where((name) => name.isNotEmpty)
        .toList();
    final defaultEmployee = activeEmployees.isNotEmpty
        ? activeEmployees.first
        : 'Unassigned';

    setState(() {
      _phoneCtrl.clear();
      _selectedCategory = 'All';
      _selectedServiceIds.clear();
      _employee = defaultEmployee;
      _paymentType = 'Cash';
    });
  }

  void _scrollToServices() {
    final targetContext = _servicesSectionKey.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      alignment: 0.05,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _PhoneMatch {
  const _PhoneMatch({required this.phone});

  final String phone;
}

