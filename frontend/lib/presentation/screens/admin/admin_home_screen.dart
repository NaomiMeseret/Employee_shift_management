import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/analytics_chart.dart';
import '../../states/auth_notifier.dart';
import '../../states/employee_notifier.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeState = ref.watch(employeeProvider);
    final user = ref.watch(authProvider).user;

    // Fetch data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeProvider.notifier).fetchEmployees();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Admin Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutDialog(context, ref);
            },
            icon: const Icon(Icons.logout),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.1),
              foregroundColor: AppColors.error,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(employeeProvider.notifier).fetchEmployees();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              _buildWelcomeCard(context, user?.name ?? 'Admin'),
              const SizedBox(height: AppSpacing.lg),
              
              // Quick Stats
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildStatsGrid(context, employeeState),
              const SizedBox(height: AppSpacing.xl),
              
              // Analytics Chart
              _buildAnalyticsSection(context),
              const SizedBox(height: AppSpacing.xl),
              
              // Quick Actions
              _buildQuickActions(context),
              const SizedBox(height: AppSpacing.xl),
              
              // Recent Activities
              _buildRecentActivities(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String adminName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.dashboard,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, $adminName!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Manage your team efficiently with ShiftMaster',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, dynamic employeeState) {
    final totalEmployees = employeeState.employees.length;
    final activeEmployees = employeeState.employees.where((e) => e.status?.toLowerCase() == 'active').length;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        StatsCard(
          title: 'Total Employees',
          value: totalEmployees.toString(),
          icon: Icons.people,
          color: AppColors.primary,
          onTap: () => Navigator.pushNamed(context, '/admin/employees'),
        ),
        StatsCard(
          title: 'Active Employees',
          value: activeEmployees.toString(),
          icon: Icons.person,
          color: AppColors.success,
        ),
        StatsCard(
          title: 'Today\'s Shifts',
          value: '8',
          icon: Icons.schedule,
          color: AppColors.secondary,
          onTap: () => Navigator.pushNamed(context, '/admin/shifts'),
        ),
        const StatsCard(
          title: 'Attendance Rate',
          value: '94%',
          icon: Icons.trending_up,
          color: AppColors.warning,
          subtitle: 'This month',
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        AnalyticsChart(
          title: 'Weekly Attendance',
          data: [
            ChartData(label: 'Mon', value: 85),
            ChartData(label: 'Tue', value: 92),
            ChartData(label: 'Wed', value: 78),
            ChartData(label: 'Thu', value: 95),
            ChartData(label: 'Fri', value: 88),
            ChartData(label: 'Sat', value: 70),
            ChartData(label: 'Sun', value: 65),
          ],
          type: ChartType.bar,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _buildActionTile(
                  context,
                  'Add New Employee',
                  'Register a new team member',
                  Icons.person_add,
                  AppColors.primary,
                  () => Navigator.pushNamed(context, '/admin/employees/add'),
                ),
                const Divider(),
                _buildActionTile(
                  context,
                  'Assign Shifts',
                  'Schedule shifts for employees',
                  Icons.calendar_today,
                  AppColors.secondary,
                  () => Navigator.pushNamed(context, '/admin/shifts'),
                ),
                const Divider(),
                _buildActionTile(
                  context,
                  'View Reports',
                  'Generate attendance reports',
                  Icons.assessment,
                  AppColors.success,
                  () => _showComingSoonDialog(context),
                ),
                const Divider(),
                _buildActionTile(
                  context,
                  'Manage Users',
                  'Approve pending user registrations',
                  Icons.admin_panel_settings,
                  AppColors.warning,
                  () => Navigator.pushNamed(context, '/admin/users'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _buildActivityItem(
                  'New employee John Doe registered',
                  '2 hours ago',
                  Icons.person_add,
                  AppColors.success,
                ),
                const Divider(),
                _buildActivityItem(
                  'Morning shift assigned to 5 employees',
                  '4 hours ago',
                  Icons.schedule,
                  AppColors.primary,
                ),
                const Divider(),
                _buildActivityItem(
                  'Sarah Smith clocked out',
                  '6 hours ago',
                  Icons.access_time,
                  AppColors.secondary,
                ),
                const Divider(),
                _buildActivityItem(
                  'Weekly attendance report generated',
                  '1 day ago',
                  Icons.assessment,
                  AppColors.warning,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Employees',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'Shifts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            Navigator.pushNamed(context, '/admin/employees');
            break;
          case 2:
            Navigator.pushNamed(context, '/admin/shifts');
            break;
          case 3:
            _showComingSoonDialog(context);
            break;
        }
      },
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
} 