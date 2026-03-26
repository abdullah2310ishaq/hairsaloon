import 'package:hairsaloon/src/features/employees/domain/entities/employee_item.dart';

class LocalEmployeesStore {
  LocalEmployeesStore._();

  static final List<EmployeeItem> _employees = [
    const EmployeeItem(
      id: 'emp-1',
      firstName: 'Ali',
      lastName: 'Raza',
      phoneNumber: '+923001234567',
      cnicNumber: '35202-1234567-1',
      homeAddress: 'G-11 Markaz, Islamabad',
      isActive: true,
      employeeType: 'Stylist',
      basicSalary: '40000',
      commission: '10',
      agreementDescription: 'Monthly salary plus service commission.',
    ),
    const EmployeeItem(
      id: 'emp-2',
      firstName: 'Sana',
      lastName: 'Khan',
      phoneNumber: '+923111234567',
      cnicNumber: '35202-7654321-9',
      homeAddress: 'F-10, Islamabad',
      isActive: false,
      employeeType: null,
      basicSalary: null,
      commission: null,
      agreementDescription: null,
    ),
  ];

  static List<EmployeeItem> get employees => List<EmployeeItem>.unmodifiable(_employees);

  static void add(EmployeeItem item) => _employees.insert(0, item);

  static void update(EmployeeItem item) {
    final index = _employees.indexWhere((e) => e.id == item.id);
    if (index == -1) return;
    _employees[index] = item;
  }

  static void delete(String id) => _employees.removeWhere((e) => e.id == id);
}

