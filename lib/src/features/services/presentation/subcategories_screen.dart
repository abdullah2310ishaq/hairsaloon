import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/services/data/local_category_store.dart';
import 'package:hairsaloon/src/features/services/data/local_services_store.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class SubcategoriesScreen extends StatefulWidget {
  const SubcategoriesScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<SubcategoriesScreen> createState() => _SubcategoriesScreenState();
}

class _SubcategoriesScreenState extends State<SubcategoriesScreen> {
  final TextEditingController _subcategoryController = TextEditingController();
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    final categories = LocalCategoryStore.categories;
    final requested = widget.initialCategory;
    if (requested != null && categories.contains(requested)) {
      _selectedCategory = requested;
    } else {
      _selectedCategory = categories.first;
    }
  }

  @override
  void dispose() {
    _subcategoryController.dispose();
    super.dispose();
  }

  List<String> get _subcategories =>
      LocalCategoryStore.subcategoriesFor(_selectedCategory);

  @override
  Widget build(BuildContext context) {
    final categories = LocalCategoryStore.categories;
    final subcategories = _subcategories;

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
          'Sub Categories (${subcategories.length.toString().padLeft(2, '0')})',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: _fieldDecoration('Select Category'),
            items: categories
                .map(
                  (item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedCategory = value);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _subcategoryController,
            decoration: _fieldDecoration('Enter Subcategory Name'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saveSubcategory,
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...subcategories.map(_buildSubcategoryTile),
        ],
      ),
    );
  }

  Widget _buildSubcategoryTile(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditSubcategoryDialog(name);
                  return;
                }
                if (value == 'delete') {
                  setState(() {
                    LocalCategoryStore.deleteSubcategory(
                      category: _selectedCategory,
                      subcategory: name,
                    );
                  });
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
              ],
              icon: const Icon(CupertinoIcons.ellipsis_vertical),
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

  void _saveSubcategory() {
    final value = _subcategoryController.text.trim();
    final added = LocalCategoryStore.addSubcategory(
      category: _selectedCategory,
      subcategory: value,
    );
    if (!added) return;

    _subcategoryController.clear();
    setState(() {});
  }

  Future<void> _showEditSubcategoryDialog(String oldName) async {
    final nameController = TextEditingController(text: oldName);
    final currentPrice =
        LocalServicesStore.serviceFor(
          category: _selectedCategory,
          subcategory: oldName,
        )?.price ??
        LocalServicesStore.seededPrice(_selectedCategory, oldName);
    final priceController = TextEditingController(
      text: currentPrice.toStringAsFixed(0),
    );

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Subcategory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Subcategory name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Price'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (shouldUpdate != true || !mounted) return;

    final newName = nameController.text.trim();
    final parsedPrice = double.tryParse(priceController.text.trim());
    if (newName.isEmpty || parsedPrice == null || parsedPrice <= 0) {
      _showMessage('Enter valid subcategory and price.');
      return;
    }

    final renamed = LocalCategoryStore.renameSubcategory(
      category: _selectedCategory,
      oldName: oldName,
      newName: newName,
    );
    if (!renamed) {
      _showMessage('Unable to update. Name may already exist.');
      return;
    }

    LocalServicesStore.renameSubcategory(
      category: _selectedCategory,
      oldName: oldName,
      newName: newName,
    );
    LocalServicesStore.updatePriceForSubcategory(
      category: _selectedCategory,
      subcategory: newName,
      price: parsedPrice,
    );
    setState(() {});
    _showMessage('Subcategory updated.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
