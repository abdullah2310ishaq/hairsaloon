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

