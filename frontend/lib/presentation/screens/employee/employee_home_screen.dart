import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../config/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/stats_card.dart';
import '../../states/auth_notifier.dart';
import '../../states/shift_notifier.dart';
import '../../states/attendance_notifier.dart';

class EmployeeHomeScreen extends ConsumerStatefulWidget {
  const EmployeeHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends ConsumerState<EmployeeHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(shiftProvider.notifier).fetchShifts(user.id);
        ref.read(attendanceProvider.notifier).fetchAttendanceRecords(user.id);
        ref.read(attendanceProvider.notifier).checkCurrentStatus(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final shiftState = ref.watch(shiftProvider);
    final attendanceState = ref.watch(attendanceProvider);

    final todayShifts = _getTodayShifts(shiftState.shifts);
    final upcomingShifts = _getUpcomingShifts(shiftState.shifts);
    final todayRecord = _getTodayRecord(attendanceState.records);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Welcome, ${user?.name ?? 'Employee'}',
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfileMenu(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await Future.wait([
              ref.read(shiftProvider.notifier).fetchShifts(user.id),
              ref.read(attendanceProvider.notifier).fetchAttendanceRecords(user.id),
            ]);
            await ref.read(attendanceProvider.notifier).checkCurrentStatus(user.id);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              _buildWelcomeCard(),
              const SizedBox(height: AppSpacing.xl),

              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: AppSpacing.xl),

              // Today's Overview
              _buildTodayOverview(todayShifts, todayRecord, attendanceState.isClockedIn),
              const SizedBox(height: AppSpacing.xl),

              // Quick Stats
              _buildQuickStats(shiftState.shifts, attendanceState.records),
              const SizedBox(height: AppSpacing.xl),

              // Recent Activity
              _buildRecentActivity(upcomingShifts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final user = ref.watch(authProvider).user;
    final now = DateTime.now();
    final timeOfDay = now.hour < 12 ? 'Morning' : now.hour < 17 ? 'Afternoon' : 'Evening';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
            AppColors.secondary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'E',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good $timeOfDay! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.name ?? 'Employee',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                    Text(
                      user?.position ?? 'Team Member',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    DateFormat('EEEE, MMMM d, y • HH:mm').format(now),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'My Shifts',
                'View and manage your shifts',
                Icons.calendar_today,
                AppColors.primary,
                () => Navigator.pushNamed(context, '/employee/shifts'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildActionCard(
                'Attendance',
                'Clock in/out and view history',
                Icons.access_time,
                AppColors.secondary,
                () => Navigator.pushNamed(context, '/employee/attendance'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayOverview(List<dynamic> todayShifts, dynamic todayRecord, bool isClockedIn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTodayInfo(
                        'Shifts Today',
                        todayShifts.length.toString(),
                        Icons.event,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildTodayInfo(
                        'Hours Worked',
                        '${todayRecord?.totalHours?.toStringAsFixed(1) ?? '0.0'}h',
                        Icons.timer,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
                if (todayShifts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: AppColors.warning, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Next Shift: ${todayShifts.first.shiftType}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayInfo(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(List<dynamic> shifts, List<dynamic> records) {
    final thisWeekShifts = _getThisWeekShifts(shifts);
    final thisWeekHours = _getThisWeekHours(records);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.3,
          children: [
            StatsCard(
              title: 'Shifts',
              value: thisWeekShifts.length.toString(),
              icon: Icons.calendar_view_week,
              color: AppColors.primary,
              subtitle: 'this week',
            ),
            StatsCard(
              title: 'Hours',
              value: '${thisWeekHours.toStringAsFixed(1)}h',
              icon: Icons.access_time,
              color: AppColors.secondary,
              subtitle: 'worked',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(List<dynamic> upcomingShifts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Shifts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/employee/shifts'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (upcomingShifts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.event_available,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No upcoming shifts',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...upcomingShifts.take(3).map((shift) => _buildShiftPreview(shift)),
      ],
    );
  }

  Widget _buildShiftPreview(dynamic shift) {
    final shiftColor = _getShiftColor(shift.shiftType);
    final shiftIcon = _getShiftIcon(shift.shiftType);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: shiftColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(shiftIcon, color: shiftColor),
        ),
        title: Text(
          shift.shiftType,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(_formatDate(DateTime.parse(shift.date))),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _getShiftColor(shift.shiftType),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            shift.status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/employee/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/employee/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  List<dynamic> _getTodayShifts(List<dynamic> shifts) {
    final today = DateTime.now();
    return shifts.where((shift) {
      final shiftDate = DateTime.parse(shift.date);
      return shiftDate.year == today.year &&
             shiftDate.month == today.month &&
             shiftDate.day == today.day;
    }).toList();
  }

  List<dynamic> _getUpcomingShifts(List<dynamic> shifts) {
    final now = DateTime.now();
    return shifts.where((shift) {
      final shiftDate = DateTime.parse(shift.date);
      return shiftDate.isAfter(now);
    }).toList()
      ..sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
  }

  List<dynamic> _getThisWeekShifts(List<dynamic> shifts) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return shifts.where((shift) {
      final shiftDate = DateTime.parse(shift.date);
      return shiftDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             shiftDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  dynamic _getTodayRecord(List<dynamic> records) {
    final today = DateTime.now();
    try {
      return records.firstWhere((record) {
        final recordDate = DateTime.parse(record.date);
        return recordDate.year == today.year &&
               recordDate.month == today.month &&
               recordDate.day == today.day;
      });
    } catch (e) {
      return null;
    }
  }

  double _getThisWeekHours(List<dynamic> records) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final weekRecords = records.where((record) {
      final recordDate = DateTime.parse(record.date);
      return recordDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             recordDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    });

    return weekRecords.fold<double>(0.0, (sum, record) => sum + (record.totalHours ?? 0.0));
  }

  Color _getShiftColor(String shiftType) {
    switch (shiftType.toLowerCase()) {
      case 'morning':
        return AppColors.warning;
      case 'afternoon':
        return AppColors.primary;
      case 'evening':
        return AppColors.secondary;
      case 'night':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getShiftIcon(String shiftType) {
    switch (shiftType.toLowerCase()) {
      case 'morning':
        return Icons.wb_sunny;
      case 'afternoon':
        return Icons.wb_cloudy;
      case 'evening':
        return Icons.wb_twilight;
      case 'night':
        return Icons.nights_stay;
      default:
        return Icons.schedule;
    }
  }
}
