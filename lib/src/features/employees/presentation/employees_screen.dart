import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/router/app_routes.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Employees list placeholder'),
          ),
          ListTile(
            title: const Text('Open Agreement'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.employeeAgreement);
            },
          ),
        ],
      ),
    );
  }
}

