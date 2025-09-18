import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../config/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/stats_card.dart';
import '../../states/attendance_notifier.dart';
import '../../states/auth_notifier.dart';
import '../../../domain/entities/attendance.dart';

class EmployeeAttendanceScreen extends ConsumerStatefulWidget {
  const EmployeeAttendanceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends ConsumerState<EmployeeAttendanceScreen> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  bool _showHistory = false;
  String _selectedPeriod = 'This Week';

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(attendanceProvider.notifier).fetchAttendanceRecords(user.id);
        ref.read(attendanceProvider.notifier).checkCurrentStatus(user.id);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider);
    final user = ref.watch(authProvider).user;
    final records = attendanceState.records;
    final isLoading = attendanceState.isLoading;
    final error = attendanceState.error;

    final filteredRecords = _filterRecordsByPeriod(records, _selectedPeriod);
    final todayRecord = _getTodayRecord(records);
    final weekStats = _getWeekStats(records);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Attendance',
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await ref.read(attendanceProvider.notifier).fetchAttendanceRecords(user.id);
            await ref.read(attendanceProvider.notifier).checkCurrentStatus(user.id);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentTimeCard(todayRecord, attendanceState.isClockedIn),
              const SizedBox(height: AppSpacing.xl),
              _buildClockActions(user, attendanceState.isClockedIn, isLoading),
              const SizedBox(height: AppSpacing.xl),
              _buildQuickStats(weekStats, todayRecord),
              const SizedBox(height: AppSpacing.xl),
              _buildViewToggle(),
              const SizedBox(height: AppSpacing.lg),
              if (_showHistory) ...[
                _buildPeriodFilter(),
                const SizedBox(height: AppSpacing.lg),
                _buildAttendanceHistory(filteredRecords),
              ] else ...[
                _buildTodaySummary(todayRecord),
                const SizedBox(height: AppSpacing.lg),
                _buildRecentActivity(records.take(5).toList()),
              ],
              if (isLoading && records.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (error != null) _buildErrorState(error),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeCard(Attendance? todayRecord, bool isClockedIn) {
    final timeString = _formatTime(_currentTime);
    final dateString = _formatDate(_currentTime);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Text(
              timeString,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              dateString,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isClockedIn ? Icons.access_time : Icons.schedule,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    isClockedIn ? 'Currently Clocked In' : 'Not Clocked In',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockActions(dynamic user, bool isClockedIn, bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (!isClockedIn && !isLoading && user != null) 
              ? () => _clockIn(user.id) 
              : null,
            icon: isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.login),
            label: const Text('Clock In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (isClockedIn && !isLoading && user != null) 
              ? () => _clockOut(user.id) 
              : null,
            icon: isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.logout),
            label: const Text('Clock Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> weekStats, Attendance? todayRecord) {
    final todayHours = todayRecord?.totalHours ?? 0.0;
    final weekHours = weekStats['totalHours'] ?? 0.0;
    final daysWorked = weekStats['daysWorked'] ?? 0;
    final avgHours = weekStats['avgHours'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week Overview',
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
              title: 'Today',
              value: '${todayHours.toStringAsFixed(1)}h',
              icon: Icons.today,
              color: AppColors.primary,
              subtitle: 'hours worked',
            ),
            StatsCard(
              title: 'This Week',
              value: '${weekHours.toStringAsFixed(1)}h',
              icon: Icons.calendar_view_week,
              color: AppColors.secondary,
              subtitle: 'total hours',
            ),
            StatsCard(
              title: 'Days Worked',
              value: daysWorked.toString(),
              icon: Icons.event_available,
              color: AppColors.success,
              subtitle: 'this week',
            ),
            StatsCard(
              title: 'Daily Average',
              value: '${avgHours.toStringAsFixed(1)}h',
              icon: Icons.trending_up,
              color: AppColors.warning,
              subtitle: 'per day',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showHistory = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: !_showHistory ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  'Today',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_showHistory ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showHistory = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: _showHistory ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  'History',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _showHistory ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(Attendance? todayRecord) {
    if (todayRecord == null || todayRecord.id.isEmpty) {
      return _buildEmptyState('No attendance record for today', Icons.event_note);
    }

    final clockInTime = todayRecord.clockInTime != null 
      ? _parseTimeString(todayRecord.clockInTime!) 
      : null;
    final clockOutTime = todayRecord.clockOutTime != null 
      ? _parseTimeString(todayRecord.clockOutTime!) 
      : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Today\'s Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _buildTimeInfo(
                    'Clock In',
                    clockInTime != null ? _formatTime(clockInTime) : '--:--',
                    Icons.login,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildTimeInfo(
                    'Clock Out',
                    clockOutTime != null ? _formatTime(clockOutTime) : '--:--',
                    Icons.logout,
                    AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Hours',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${todayRecord.totalHours.toStringAsFixed(2)} hours',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            time,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    final periods = ['This Week', 'Last Week', 'This Month', 'Last Month'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAttendanceHistory(List<Attendance> records) {
    if (records.isEmpty) {
      return _buildEmptyState('No attendance records found', Icons.history);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...records.map((record) => _buildAttendanceCard(record)),
      ],
    );
  }

  Widget _buildRecentActivity(List<Attendance> recentRecords) {
    if (recentRecords.isEmpty) {
      return _buildEmptyState('No recent activity', Icons.history);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...recentRecords.map((record) => _buildAttendanceCard(record)),
      ],
    );
  }

  Widget _buildAttendanceCard(Attendance record) {
    final date = DateTime.parse(record.date);
    final clockInTime = record.clockInTime != null 
      ? _parseTimeString(record.clockInTime!) 
      : null;
    final clockOutTime = record.clockOutTime != null 
      ? _parseTimeString(record.clockOutTime!) 
      : null;
    final isToday = _isSameDay(date, DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: isToday ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: isToday 
          ? const BorderSide(color: AppColors.primary, width: 2)
          : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _formatDate(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    '${record.totalHours.toStringAsFixed(1)}h',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.login,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        clockInTime != null ? _formatTime(clockInTime) : '--:--',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        clockOutTime != null ? _formatTime(clockOutTime) : '--:--',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Error loading attendance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () {
              final user = ref.read(authProvider).user;
              if (user != null) {
                ref.read(attendanceProvider.notifier).fetchAttendanceRecords(user.id);
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  Future<void> _clockIn(String userId) async {
    try {
      await ref.read(attendanceProvider.notifier).clockIn(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully clocked in!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clock in: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _clockOut(String userId) async {
    try {
      await ref.read(attendanceProvider.notifier).clockOut(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully clocked out!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clock out: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Helper methods
  List<Attendance> _filterRecordsByPeriod(List<Attendance> records, String period) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (period) {
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Last Week':
        final lastWeekEnd = now.subtract(Duration(days: now.weekday));
        startDate = lastWeekEnd.subtract(const Duration(days: 6));
        endDate = lastWeekEnd;
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Last Month':
        startDate = DateTime(now.year, now.month - 1, 1);
        endDate = DateTime(now.year, now.month, 0);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    return records.where((record) {
      final recordDate = DateTime.parse(record.date);
      return recordDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             recordDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
  }

  Attendance? _getTodayRecord(List<Attendance> records) {
    final today = DateTime.now();
    try {
      return records.firstWhere(
        (record) => _isSameDay(DateTime.parse(record.date), today),
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _getWeekStats(List<Attendance> records) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final weekRecords = records.where((record) {
      final recordDate = DateTime.parse(record.date);
      return recordDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             recordDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();

    final totalHours = weekRecords.fold<double>(0.0, (sum, record) => sum + record.totalHours);
    final daysWorked = weekRecords.where((record) => record.totalHours > 0).length;
    final avgHours = daysWorked > 0 ? totalHours / daysWorked : 0.0;

    return {
      'totalHours': totalHours,
      'daysWorked': daysWorked,
      'avgHours': avgHours,
    };
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  DateTime? _parseTimeString(String timeString) {
    try {
      // Handle different time formats
      if (timeString.contains('T')) {
        // ISO format like "2025-01-17T14:30:00"
        return DateTime.parse(timeString);
      } else if (timeString.contains(':')) {
        // Time only format like "14:30"
        final now = DateTime.now();
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          return DateTime(now.year, now.month, now.day, hour, minute);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
