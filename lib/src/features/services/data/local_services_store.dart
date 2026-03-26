import 'package:hairsaloon/src/features/services/domain/entities/service_item.dart';

class LocalServicesStore {
  LocalServicesStore._();

  static final List<ServiceItem> _services = [
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
      serviceName: 'Beard Trim',
      gender: 'Male',
      ageGroup: 'Adult',
      price: 350,
    ),
    ServiceItem(
      id: '3',
      category: "Men's Grooming",
      serviceName: 'Shave',
      gender: 'Male',
      ageGroup: 'Adult',
      price: 300,
    ),
    ServiceItem(
      id: '4',
      category: 'Skincare & Facials',
      serviceName: 'Facial Basic',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 1500,
    ),
    ServiceItem(
      id: '5',
      category: 'Skincare & Facials',
      serviceName: 'Whitening Facial',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 2200,
    ),
    ServiceItem(
      id: '6',
      category: 'Hair',
      serviceName: 'Hair Color',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 2500,
    ),
    ServiceItem(
      id: '7',
      category: 'Hair',
      serviceName: 'Hair Spa',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 1800,
    ),
    ServiceItem(
      id: '8',
      category: 'Packages',
      serviceName: 'Groom Package',
      gender: 'Male',
      ageGroup: 'Adult',
      price: 2800,
    ),
    ServiceItem(
      id: '9',
      category: 'Packages',
      serviceName: 'Bridal Package',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 8500,
    ),
    ServiceItem(
      id: '10',
      category: 'Child',
      serviceName: 'Kids Hair Cut',
      gender: 'Male',
      ageGroup: 'Child',
      price: 500,
    ),
    ServiceItem(
      id: '11',
      category: 'Women',
      serviceName: 'Threading',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 300,
    ),
    ServiceItem(
      id: '12',
      category: 'Women',
      serviceName: 'Waxing Arms',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 1200,
    ),
    ServiceItem(
      id: '13',
      category: 'Skincare & Facials',
      serviceName: 'Cleanup',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 900,
    ),
    ServiceItem(
      id: '14',
      category: 'Hair',
      serviceName: 'Blow Dry',
      gender: 'Female',
      ageGroup: 'Adult',
      price: 700,
    ),
  ];

  static List<ServiceItem> get services => List<ServiceItem>.unmodifiable(_services);

  static List<String> get categories {
    final unique = _services.map((e) => e.category).toSet().toList()..sort();
    return unique;
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
}

