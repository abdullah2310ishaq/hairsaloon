import 'package:hairsaloon/src/features/expenses/domain/entities/expense_item.dart';

class LocalExpensesStore {
  LocalExpensesStore._();

  static final List<ExpenseItem> _items = [
    ExpenseItem(
      id: 'exp-1',
      date: DateTime(2026, 3, 17),
      employeeName: 'Ali Raza',
      amount: 100,
      status: 'Paid',
      paymentType: 'Cash',
      expenseType: 'Tea/Coffee',
      quantity: 1,
      description: 'Buy some coffee',
      createdAt: DateTime(2026, 3, 17, 14, 15),
    ),
    ExpenseItem(
      id: 'exp-2',
      date: DateTime(2026, 3, 17),
      employeeName: 'Sana Khan',
      amount: 100,
      status: 'Unpaid',
      paymentType: 'Online',
      expenseType: 'Cleaning',
      quantity: 1,
      description: 'Buy some coffee',
      createdAt: DateTime(2026, 3, 17, 14, 15),
    ),
  ];

  static List<ExpenseItem> get items => List<ExpenseItem>.unmodifiable(_items);

  static void add(ExpenseItem item) => _items.insert(0, item);

  static void update(ExpenseItem item) {
    final index = _items.indexWhere((element) => element.id == item.id);
    if (index == -1) return;
    _items[index] = item;
  }

  static void delete(String id) => _items.removeWhere((item) => item.id == id);
}
