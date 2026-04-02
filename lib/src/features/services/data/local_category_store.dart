import 'dart:collection';

class LocalCategoryStore {
  LocalCategoryStore._();

  static final List<String> _categories = [
    'Hair Care & Styling',
    'Nail Care',
    'Skincare & Facials',
    'Hair Removal',
    'Eye & Makeup',
    'Body & Wellness',
    "Men's Grooming",
    'Bridal Services',
    'Kids Services',
    'Spa & Massage',
    'Hair Treatments',
    'Packages',
  ];

  static final LinkedHashMap<String, List<String>> _subcategoriesByCategory =
      LinkedHashMap<String, List<String>>.fromEntries(
        _categories.map((category) => MapEntry(category, <String>[])),
      )..addAll(<String, List<String>>{
        'Hair Care & Styling': <String>[
          'Simple Cutting',
          'Buzzcuts',
          'Layers Cut',
          'Trims',
        ],
        'Nail Care': <String>['Manicure', 'Pedicure'],
        'Skincare & Facials': <String>['Cleanup', 'Basic Facial'],
        'Hair Removal': <String>['Threading', 'Waxing Arms'],
        'Eye & Makeup': <String>['Eye Makeup', 'Party Makeup'],
        'Body & Wellness': <String>['Body Polish'],
        "Men's Grooming": <String>['Beard Trim', 'Shave'],
        'Bridal Services': <String>['Bridal Makeup'],
        'Kids Services': <String>['Kids Hair Cut'],
        'Spa & Massage': <String>['Head Massage'],
        'Hair Treatments': <String>['Hair Spa', 'Keratin'],
        'Packages': <String>['Groom Package', 'Bridal Package'],
      });

  static List<String> get categories => List<String>.unmodifiable(_categories);

  static List<String> subcategoriesFor(String category) {
    final values = _subcategoriesByCategory[category] ?? const <String>[];
    return List<String>.unmodifiable(values);
  }

  static bool addSubcategory({
    required String category,
    required String subcategory,
  }) {
    final normalized = subcategory.trim();
    if (normalized.isEmpty) return false;

    final values = _subcategoriesByCategory[category];
    if (values == null) return false;

    final exists = values.any(
      (item) => item.toLowerCase() == normalized.toLowerCase(),
    );
    if (exists) return false;

    values.insert(0, normalized);
    return true;
  }

  static void deleteSubcategory({
    required String category,
    required String subcategory,
  }) {
    final values = _subcategoriesByCategory[category];
    if (values == null) return;

    values.removeWhere(
      (item) => item.toLowerCase() == subcategory.trim().toLowerCase(),
    );
  }

  static bool renameSubcategory({
    required String category,
    required String oldName,
    required String newName,
  }) {
    final values = _subcategoriesByCategory[category];
    if (values == null) return false;

    final normalizedOld = oldName.trim();
    final normalizedNew = newName.trim();
    if (normalizedOld.isEmpty || normalizedNew.isEmpty) return false;

    final index = values.indexWhere(
      (item) => item.toLowerCase() == normalizedOld.toLowerCase(),
    );
    if (index == -1) return false;

    final duplicate = values.any(
      (item) =>
          item.toLowerCase() == normalizedNew.toLowerCase() &&
          item.toLowerCase() != normalizedOld.toLowerCase(),
    );
    if (duplicate) return false;

    values[index] = normalizedNew;
    return true;
  }
}
