class EmployeeItem {
  const EmployeeItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.cnicNumber,
    required this.homeAddress,
    required this.isActive,
    this.speciality,
    this.employeeType,
    this.basicSalary,
    this.commission,
    this.agreementDescription,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String cnicNumber;
  final String homeAddress;
  final bool isActive;
  final String? speciality;
  final String? employeeType;
  final String? basicSalary;
  final String? commission;
  final String? agreementDescription;

  String get fullName => '$firstName $lastName'.trim();

  EmployeeItem copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? cnicNumber,
    String? homeAddress,
    bool? isActive,
    String? speciality,
    String? employeeType,
    String? basicSalary,
    String? commission,
    String? agreementDescription,
  }) {
    return EmployeeItem(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cnicNumber: cnicNumber ?? this.cnicNumber,
      homeAddress: homeAddress ?? this.homeAddress,
      isActive: isActive ?? this.isActive,
      speciality: speciality ?? this.speciality,
      employeeType: employeeType ?? this.employeeType,
      basicSalary: basicSalary ?? this.basicSalary,
      commission: commission ?? this.commission,
      agreementDescription: agreementDescription ?? this.agreementDescription,
    );
  }
}
