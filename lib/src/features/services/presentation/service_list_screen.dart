import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final List<ServiceItem> _services = [
    ServiceItem(
      id: '1',
      category: "Men's Grooming",
      serviceName: 'Hair Cut',
      gender: 'Male',
      ageGroup: 'Adult',
      price: 400,
    ),
    ServiceItem(
      id: '2',
      category: "Men's Grooming",
      serviceName: 'Hair Cut',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 600,
    ),
    ServiceItem(
      id: '3',
      category: "Men's Grooming",
      serviceName: 'Hair Cut',
      gender: 'Male',
      ageGroup: 'Child',
      price: 800,
    ),
    ServiceItem(
      id: '4',
      category: 'Skincare & Facials',
      serviceName: 'Facial',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 1500,
    ),
  ];

  final List<String> _categories = [
    "Men's Grooming",
    'Skincare & Facials',
    'Male',
    'Female',
    'Child',
  ];

  final _formKey = GlobalKey<FormState>();
  bool _showAddForm = false;
  String _selectedCategoryTab = "Men's Grooming";

  String? _newCategoryDropdown;
  String _newCategoryCustom = '';
  String _newServiceName = '';
  String? _newGender;
  String? _newAgeGroup;
  String _newPrice = '';

  List<ServiceItem> get _filteredServices => _services
      .where((s) => s.category == _selectedCategoryTab)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back),
          color: Colors.black,
        ),
        title: Text(
          'Rate List (${_services.length.toString().padLeft(2, '0')})',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showAddForm = !_showAddForm;
              });
            },
            icon: Icon(
              _showAddForm ? CupertinoIcons.xmark : CupertinoIcons.add,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = category == _selectedCategoryTab;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  selectedColor: Colors.white,
                  backgroundColor: const Color(0xFFF8F8F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedCategoryTab = category;
                    });
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemCount: _categories.length,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              children: [
                if (_showAddForm) ...[
                  _buildAddFormCard(context),
                  const SizedBox(height: 10),
                ],
                ..._filteredServices.map((item) => _ServiceTile(
                      item: item,
                      onEdit: () => _openEditDialog(item),
                      onDelete: () {
                        setState(() {
                          _services.removeWhere((s) => s.id == item.id);
                        });
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Service',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _newCategoryDropdown,
              decoration: _fieldDecoration('Select Category'),
              items: _categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _newCategoryDropdown = value),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: _fieldDecoration('Or Enter New Category'),
              onChanged: (value) => _newCategoryCustom = value.trim(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: _fieldDecoration('Select Service'),
              onChanged: (value) => _newServiceName = value.trim(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter service.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _newGender,
              decoration: _fieldDecoration('Select Gender'),
              items: const ['Male', 'Female', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _newGender = value),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _newAgeGroup,
              decoration: _fieldDecoration('Select Age Group'),
              items: const ['Adult', 'Child']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _newAgeGroup = value),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: _fieldDecoration('Enter Price'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _newPrice = value.trim(),
              validator: (value) {
                final parsed = double.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Please enter valid price.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveService,
                child: const Text(
                  'Save Service',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  void _saveService() {
    final state = _formKey.currentState;
    if (state == null || !state.validate()) return;
    if (_newGender == null || _newAgeGroup == null) return;

    final category = _newCategoryCustom.isNotEmpty
        ? _newCategoryCustom
        : (_newCategoryDropdown ?? _selectedCategoryTab);
    if (!_categories.contains(category)) {
      _categories.add(category);
    }

    setState(() {
      _services.insert(
        0,
        ServiceItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          category: category,
          serviceName: _newServiceName,
          gender: _newGender!,
          ageGroup: _newAgeGroup!,
          price: double.parse(_newPrice),
        ),
      );
      _selectedCategoryTab = category;
      _showAddForm = false;
      _newCategoryDropdown = null;
      _newCategoryCustom = '';
      _newServiceName = '';
      _newGender = null;
      _newAgeGroup = null;
      _newPrice = '';
      _formKey.currentState?.reset();
    });
  }

  Future<void> _openEditDialog(ServiceItem item) async {
    final serviceCtrl = TextEditingController(text: item.serviceName);
    final priceCtrl = TextEditingController(text: item.price.toStringAsFixed(0));
    String category = item.category;
    String gender = item.gender;
    String ageGroup = item.ageGroup;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Service'),
          content: StatefulBuilder(
            builder: (context, setLocal) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: category,
                      items: _categories
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setLocal(() => category = v);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: serviceCtrl),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: gender,
                      items: const ['Male', 'Female', 'Other']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setLocal(() => gender = v);
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: ageGroup,
                      items: const ['Adult', 'Child']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setLocal(() => ageGroup = v);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = double.tryParse(priceCtrl.text.trim());
                if (parsed == null || serviceCtrl.text.trim().isEmpty) return;
                setState(() {
                  final idx = _services.indexWhere((s) => s.id == item.id);
                  if (idx == -1) return;
                  _services[idx] = item.copyWith(
                    category: category,
                    serviceName: serviceCtrl.text.trim(),
                    gender: gender,
                    ageGroup: ageGroup,
                    price: parsed,
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final ServiceItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: const TextStyle(fontSize: 11, color: Colors.blue),
                ),
                const SizedBox(height: 2),
                Text(
                  item.serviceName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(item.gender),
          const SizedBox(width: 16),
          Text(item.ageGroup),
          const SizedBox(width: 16),
          Text(
            'Rs.${item.price.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.green),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Update')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            icon: const Icon(CupertinoIcons.ellipsis_vertical),
          ),
        ],
      ),
    );
  }
}

class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.category,
    required this.serviceName,
    required this.gender,
    required this.ageGroup,
    required this.price,
  });

  final String id;
  final String category;
  final String serviceName;
  final String gender;
  final String ageGroup;
  final double price;

  ServiceItem copyWith({
    String? id,
    String? category,
    String? serviceName,
    String? gender,
    String? ageGroup,
    double? price,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      category: category ?? this.category,
      serviceName: serviceName ?? this.serviceName,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      price: price ?? this.price,
    );
  }
}

