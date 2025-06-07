import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Employees', icon: Icon(Icons.people)),
              Tab(text: 'Shifts', icon: Icon(Icons.schedule)),
              Tab(text: 'Attendance', icon: Icon(Icons.check_circle)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Employees Section')), // Placeholder
            Center(child: Text('Shifts Section')),    // Placeholder
            Center(child: Text('Attendance Section')), // Placeholder
          ],
        ),
      ),
    );
  }
} 