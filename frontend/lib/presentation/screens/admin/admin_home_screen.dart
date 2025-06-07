import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_navigation_bar.dart';
import '../../states/auth_notifier.dart';
// import '../../widgets/admin_header.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.jpg', height: 32),
            const SizedBox(width: 8),
            const Text('Admin Dashboard'),
          ],
        ),
      ),
      body: Column(
        children: [
          AdminNavigationBar(currentIndex: 0),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Welcome to the Admin Dashboard!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Here you can manage employees, assign shifts, track attendance, and oversee all aspects of the Employee Shift Management System.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Employees', '24'),
                _buildStatItem('Active Shifts', '12'),
                _buildStatItem('Pending Requests', '3'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem('New shift assigned to John Doe'),
            _buildActivityItem('Sarah Smith requested time off'),
            _buildActivityItem('Team meeting scheduled for tomorrow'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(activity),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamOverview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTeamMemberItem('John Doe', 'Morning Shift'),
            _buildTeamMemberItem('Sarah Smith', 'Afternoon Shift'),
            _buildTeamMemberItem('Mike Johnson', 'Night Shift'),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberItem(String name, String shift) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  shift,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show options menu
            },
          ),
        ],
      ),
    );
  }
} 