import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/router/app_routes.dart';

class FinanceOverviewScreen extends StatelessWidget {
  const FinanceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Overview'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Today sale & profit placeholder'),
          ),
          ListTile(
            title: const Text('Employee earnings'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.employeeEarnings);
            },
          ),
        ],
      ),
    );
  }
}

