import 'package:flutter/material.dart';

const Color kPrimaryGreen = Color(0xFF2E5D47);

class AdminNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AdminNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              context,
              icon: Icons.dashboard,
              label: 'Dashboard',
              index: 0,
              route: '/admin',
            ),
            _buildNavItem(
              context,
              icon: Icons.people,
              label: 'Employees',
              index: 1,
              route: '/admin/employees',
            ),
            _buildNavItem(
              context,
              icon: Icons.access_time,
              label: 'Shifts',
              index: 2,
              route: '/admin/shifts',
            ),
            _buildNavItem(
              context,
              icon: Icons.calendar_today,
              label: 'Attendance',
              index: 3,
              route: '/admin/attendance',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required int index, required String route}) {
    final isSelected = currentIndex == index;
    final color = isSelected ? kPrimaryGreen : Colors.grey;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(label, style: TextStyle(color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
} 