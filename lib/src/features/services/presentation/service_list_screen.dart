import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/services/data/local_services_store.dart';
import 'package:hairsaloon/src/features/services/domain/entities/service_item.dart';
import 'package:hairsaloon/src/features/services/presentation/service_details_screen.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showAddForm = false;
  String _selectedCategoryTab = 'All';

  String? _newCategoryDropdown;
  String _newCategoryCustom = '';
  String _newServiceName = '';
  String? _newGender;
  String? _newAgeGroup;
  String _newPrice = '';
  List<ServiceItem> get _services => LocalServicesStore.services;
  List<String> get _categories => ['All', ...LocalServicesStore.categories];

  List<ServiceItem> get _filteredServices {
    if (_selectedCategoryTab == 'All') return List<ServiceItem>.from(_services);
    return _services
        .where((s) => s.category == _selectedCategoryTab)
        .toList(growable: false);
  }

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
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = category == _selectedCategoryTab;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  selectedColor: Colors.white,
                  backgroundColor: const Color(0xFFF8F8F8),
                  side: BorderSide(
                    color: selected
                        ? AppColors.primary
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
              children: [
                if (_showAddForm) ...[
                  _buildAddFormCard(context),
                  const SizedBox(height: 14),
                ],
                ..._filteredServices.map(
                  (item) => _ServiceTile(
                    item: item,
                    onTap: () => _openDetails(item),
                    onEdit: () => _openDetails(item),
                    onDelete: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Delete Service'),
                            content: Text(
                              'Are you sure you want to delete "${item.serviceName}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(false);
                                },
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(true);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                      if (shouldDelete != true) return;
                      setState(() {
                        LocalServicesStore.deleteService(item.id);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              value: _newCategoryDropdown,
              decoration: _fieldDecoration('Select Category'),
              items: _categories
                  .where((e) => e != 'All')
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _newCategoryDropdown = value),
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              value: _newGender,
              decoration: _fieldDecoration('Select Gender'),
              items: const ['Male', 'Female', 'Other']
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _newGender = value),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              value: _newAgeGroup,
              decoration: _fieldDecoration('Select Age Group'),
              items: const ['Adult', 'Child']
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
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

    setState(() {
      LocalServicesStore.addService(
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

  Future<void> _openDetails(ServiceItem item) async {
    final updated = await Navigator.of(context).push<ServiceItem>(
      MaterialPageRoute(
        builder: (_) =>
            ServiceDetailsScreen(item: item, categories: _categories),
      ),
    );
    if (updated == null) return;

    setState(() {
      LocalServicesStore.updateService(updated);
    });
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ServiceItem item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.serviceName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  item.gender,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  item.ageGroup,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Rs.${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit Details')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  icon: const Icon(CupertinoIcons.ellipsis_vertical),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
