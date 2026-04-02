import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/services/data/local_category_store.dart';
import 'package:hairsaloon/src/theme/app_colors.dart';

class SubcategoriesScreen extends StatefulWidget {
  const SubcategoriesScreen({super.key});

  @override
  State<SubcategoriesScreen> createState() => _SubcategoriesScreenState();
}

class _SubcategoriesScreenState extends State<SubcategoriesScreen> {
  final TextEditingController _subcategoryController = TextEditingController();
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = LocalCategoryStore.categories.first;
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
                if (value != 'delete') return;
                setState(() {
                  LocalCategoryStore.deleteSubcategory(
                    category: _selectedCategory,
                    subcategory: name,
                  );
                });
              },
              itemBuilder: (context) => const [
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
}
