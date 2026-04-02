import 'package:hairsaloon/src/features/services/domain/entities/service_item.dart';
import 'package:hairsaloon/src/features/services/data/local_category_store.dart';

@Deprecated('Use ServicesStore + HiveServicesRepository instead.')
class LocalServicesStore {
  LocalServicesStore._();

  static final List<ServiceItem> _services = [
    ServiceItem(
      id: '1',
      category: 'Hair Care & Styling',
      subcategory: 'Simple Cutting',
      gender: 'Male',
      ageGroup: 'Adult',
      price: 400,
    ),
    ServiceItem(
      id: '2',
      category: "Men's Grooming",
      subcategory: 'Beard Trim',
      gender: 'Male',
      ageGroup: 'Adult',
      price: 350,
    ),
    ServiceItem(
      id: '3',
      category: "Men's Grooming",
      subcategory: 'Shave',
      gender: 'Male',
      ageGroup: 'Adult',
      price: 300,
    ),
    ServiceItem(
      id: '4',
      category: 'Skincare & Facials',
      subcategory: 'Basic Facial',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 1500,
    ),
    ServiceItem(
      id: '5',
      category: 'Skincare & Facials',
      subcategory: 'Cleanup',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 2200,
    ),
    ServiceItem(
      id: '6',
      category: 'Hair Treatments',
      subcategory: 'Keratin',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 2500,
    ),
    ServiceItem(
      id: '7',
      category: 'Hair Treatments',
      subcategory: 'Hair Spa',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 1800,
    ),
    ServiceItem(
      id: '8',
      category: 'Packages',
      subcategory: 'Groom Package',
      gender: 'Male',
      ageGroup: 'Adult',
      price: 2800,
    ),
    ServiceItem(
      id: '9',
      category: 'Packages',
      subcategory: 'Bridal Package',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 8500,
    ),
    ServiceItem(
      id: '10',
      category: 'Kids Services',
      subcategory: 'Kids Hair Cut',
      gender: 'Male',
      ageGroup: 'Child',
      price: 500,
    ),
    ServiceItem(
      id: '11',
      category: 'Hair Removal',
      subcategory: 'Threading',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 300,
    ),
    ServiceItem(
      id: '12',
      category: 'Hair Removal',
      subcategory: 'Waxing Arms',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 1200,
    ),
    ServiceItem(
      id: '13',
      category: 'Skincare & Facials',
      subcategory: 'Cleanup',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 900,
    ),
    ServiceItem(
      id: '14',
      category: 'Hair Care & Styling',
      subcategory: 'Trims',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 700,
    ),
  ];

  static List<ServiceItem> get services =>
      List<ServiceItem>.unmodifiable(_services);

  static List<String> get categories => LocalCategoryStore.categories;

  static ServiceItem? serviceFor({
    required String category,
    required String subcategory,
  }) {
    try {
      return _services.firstWhere(
        (item) => item.category == category && item.subcategory == subcategory,
      );
    } catch (_) {
      return null;
    }
  }

  static void ensureServicesForCurrentSubcategories() {
    for (final category in LocalCategoryStore.categories) {
      final subcategories = LocalCategoryStore.subcategoriesFor(category);
      for (final subcategory in subcategories) {
        final exists = _services.any(
          (item) =>
              item.category == category && item.subcategory == subcategory,
        );
        if (exists) continue;

        _services.add(
          ServiceItem(
            id: '${DateTime.now().microsecondsSinceEpoch}_${category}_$subcategory',
            category: category,
            subcategory: subcategory,
            gender: 'Other',
            ageGroup: 'Adult',
            price: _seededPrice(category, subcategory),
          ),
        );
      }
    }
  }

  static double seededPrice(String category, String subcategory) {
    return _seededPrice(category, subcategory);
  }

  static void addService(ServiceItem service) {
    _services.insert(0, service);
  }

  static void updateService(ServiceItem service) {
    final idx = _services.indexWhere((e) => e.id == service.id);
    if (idx == -1) return;
    _services[idx] = service;
  }

  static void deleteService(String id) {
    _services.removeWhere((e) => e.id == id);
  }

  static void renameSubcategory({
    required String category,
    required String oldName,
    required String newName,
  }) {
    final normalizedOld = oldName.trim();
    final normalizedNew = newName.trim();
    if (normalizedOld.isEmpty || normalizedNew.isEmpty) return;

    for (var i = 0; i < _services.length; i++) {
      final service = _services[i];
      if (service.category != category) continue;
      if (service.subcategory.toLowerCase() != normalizedOld.toLowerCase()) {
        continue;
      }
      _services[i] = service.copyWith(subcategory: normalizedNew);
    }
  }

  static void updatePriceForSubcategory({
    required String category,
    required String subcategory,
    required double price,
  }) {
    if (price <= 0) return;
    final normalized = subcategory.trim();
    if (normalized.isEmpty) return;

    var found = false;
    for (var i = 0; i < _services.length; i++) {
      final service = _services[i];
      if (service.category != category) continue;
      if (service.subcategory.toLowerCase() != normalized.toLowerCase()) {
        continue;
      }
      _services[i] = service.copyWith(price: price);
      found = true;
    }

    if (found) return;
    _services.add(
      ServiceItem(
        id: '${DateTime.now().microsecondsSinceEpoch}_${category}_$subcategory',
        category: category,
        subcategory: normalized,
        gender: 'Other',
        ageGroup: 'Adult',
        price: price,
      ),
    );
  }

  static double _seededPrice(String category, String subcategory) {
    final hash = (category + subcategory).codeUnits.fold<int>(
      0,
      (value, unit) => value + unit,
    );
    final bucket = hash % 31; // 0..30
    return (300 + (bucket * 100)).toDouble(); // 300..3300
  }
}
