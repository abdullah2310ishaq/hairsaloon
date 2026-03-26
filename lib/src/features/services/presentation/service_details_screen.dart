import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/services/domain/entities/service_item.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({
    super.key,
    required this.item,
    required this.categories,
  });

  final ServiceItem item;
  final List<String> categories;

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  late final TextEditingController _serviceController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late String _gender;
  late String _ageGroup;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _serviceController = TextEditingController(text: widget.item.serviceName);
    _priceController = TextEditingController(
      text: widget.item.price.toStringAsFixed(0),
    );
    _categoryController = TextEditingController(text: widget.item.category);
    _gender = widget.item.gender;
    _ageGroup = widget.item.ageGroup;
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = widget.item.copyWith(
      category: _categoryController.text,
      serviceName: _serviceController.text,
      gender: _gender,
      ageGroup: _ageGroup,
      price: double.tryParse(_priceController.text) ?? widget.item.price,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
        ),
        title: const Text(
          'Service Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? 'Cancel' : 'Edit',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
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
                          currentItem.category,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentItem.serviceName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rs.${currentItem.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _inputField(
                    controller: _categoryController,
                    hint: 'Category',
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 10),
                  _inputField(
                    controller: _serviceController,
                    hint: 'Service Name',
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: _decoration('Gender'),
                    items: const ['Male', 'Female', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: _isEditing
                        ? (v) {
                            if (v == null) return;
                            setState(() => _gender = v);
                          }
                        : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _ageGroup,
                    decoration: _decoration('Age Group'),
                    items: const ['Adult', 'Child']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: _isEditing
                        ? (v) {
                            if (v == null) return;
                            setState(() => _ageGroup = v);
                          }
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _inputField(
                    controller: _priceController,
                    hint: 'Price',
                    keyboardType: TextInputType.number,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing)
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
                        onPressed: _saveChanges,
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: _decoration(hint),
    );
  }

  void _saveChanges() {
    final serviceName = _serviceController.text.trim();
    final category = _categoryController.text.trim();
    final parsedPrice = double.tryParse(_priceController.text.trim());
    if (serviceName.isEmpty || category.isEmpty || parsedPrice == null) return;

    Navigator.of(context).pop(
      widget.item.copyWith(
        category: category,
        serviceName: serviceName,
        gender: _gender,
        ageGroup: _ageGroup,
        price: parsedPrice,
      ),
    );
  }
}

