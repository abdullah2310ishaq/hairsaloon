import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/router/app_routes.dart';

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service List'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Services list placeholder'),
          ),
          ListTile(
            title: const Text('Add New Service'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.newService);
            },
          ),
        ],
      ),
    );
  }
}

