import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {'title': 'Pets', 'icon': Icons.pets, 'route': '/pets'},
      {'title': 'Food', 'icon': Icons.restaurant, 'route': '/food'},
      {'title': 'Appointments', 'icon': Icons.calendar_month, 'route': '/appointments'},
      {'title': 'Notifications', 'icon': Icons.notifications, 'route': '/notifications'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Manager 🐾'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final service = services[index];
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, service['route']),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.teal[50],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(service['icon'], size: 60, color: Colors.teal),
                    const SizedBox(height: 10),
                    Text(service['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
