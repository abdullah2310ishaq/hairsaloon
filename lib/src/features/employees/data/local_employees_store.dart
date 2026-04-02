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
      speciality: 'Haircut Specialist',
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
      speciality: 'Color Specialist',
      employeeType: null,
      basicSalary: null,
      commission: null,
      agreementDescription: null,
    ),
    const EmployeeItem(
      id: 'emp-3',
      firstName: 'M.',
      lastName: 'Aslam',
      phoneNumber: '+923221234567',
      cnicNumber: '61101-2233445-7',
      homeAddress: 'Blue Area, Islamabad',
      isActive: true,
      speciality: 'Haircut Specialist',
      employeeType: 'Senior Barber',
      basicSalary: '50000',
      commission: '15',
      agreementDescription: 'Fixed salary with tiered commission.',
    ),
  ];

  static List<EmployeeItem> get employees =>
      List<EmployeeItem>.unmodifiable(_employees);

  static void add(EmployeeItem item) => _employees.insert(0, item);

  static void update(EmployeeItem item) {
    final index = _employees.indexWhere((e) => e.id == item.id);
    if (index == -1) return;
    _employees[index] = item;
  }

  static void delete(String id) => _employees.removeWhere((e) => e.id == id);
}
