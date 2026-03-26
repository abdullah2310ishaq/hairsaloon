import 'package:flutter/material.dart';

class ExpenseTypesScreen extends StatelessWidget {
  const ExpenseTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Types'),
      ),
      body: const Center(
        child: Text('Expense types list placeholder'),
      ),
    );
  }
}

