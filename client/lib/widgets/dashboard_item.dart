import 'package:flutter/material.dart';

class DashboardItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
 

  const DashboardItem({
    super.key,
    required this.title,
    required this.icon,
    required this.route,

  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          route,
        );
      },
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.teal),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
