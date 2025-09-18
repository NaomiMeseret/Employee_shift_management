import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../config/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/stats_card.dart';
import '../../states/shift_notifier.dart';
import '../../states/auth_notifier.dart';
import '../../../domain/entities/shift.dart';

class EmployeeShiftScreen extends ConsumerStatefulWidget {
  const EmployeeShiftScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmployeeShiftScreen> createState() => _EmployeeShiftScreenState();
}

class _EmployeeShiftScreenState extends ConsumerState<EmployeeShiftScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showUpcoming = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(shiftProvider.notifier).fetchShifts(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shiftState = ref.watch(shiftProvider);
    final user = ref.watch(authProvider).user;
    final shifts = shiftState.shifts;

    // Filter shifts
    final upcomingShifts = _getUpcomingShifts(shifts);
    final todayShifts = _getTodayShifts(shifts);
    final selectedDayShifts = _getShiftsForDate(shifts, _selectedDay);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'My Shifts',
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await ref.read(shiftProvider.notifier).fetchShifts(user.id);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats
              _buildQuickStats(shifts, todayShifts, upcomingShifts),
              const SizedBox(height: AppSpacing.xl),

              // View Toggle
              _buildViewToggle(),
              const SizedBox(height: AppSpacing.lg),

              if (_showUpcoming) ...[
                // Today's Shifts
                _buildTodayShifts(todayShifts),
                const SizedBox(height: AppSpacing.xl),

                // Upcoming Shifts
                _buildUpcomingShifts(upcomingShifts),
              ] else ...[
                // Calendar View
                _buildCalendarView(shifts),
                const SizedBox(height: AppSpacing.lg),

                // Selected Day Shifts
                _buildSelectedDayShifts(selectedDayShifts),
              ],

              const SizedBox(height: AppSpacing.xl),

              // Loading/Error States
              if (shiftState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (shiftState.error != null)
                _buildErrorState(shiftState.error!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(List<Shift> allShifts, List<Shift> todayShifts, List<Shift> upcomingShifts) {
    final thisWeekShifts = _getThisWeekShifts(allShifts);
    final completedShifts = _getCompletedShifts(allShifts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
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
              value: todayShifts.length.toString(),
              icon: Icons.today,
              color: AppColors.primary,
              subtitle: todayShifts.isEmpty ? 'No shifts' : 'shifts scheduled',
            ),
            StatsCard(
              title: 'This Week',
              value: thisWeekShifts.length.toString(),
              icon: Icons.calendar_view_week,
              color: AppColors.secondary,
              subtitle: 'shifts total',
            ),
            StatsCard(
              title: 'Upcoming',
              value: upcomingShifts.length.toString(),
              icon: Icons.schedule,
              color: AppColors.warning,
              subtitle: 'shifts pending',
            ),
            StatsCard(
              title: 'Completed',
              value: completedShifts.length.toString(),
              icon: Icons.check_circle,
              color: AppColors.success,
              subtitle: 'this month',
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
              onTap: () => setState(() => _showUpcoming = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: _showUpcoming ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  'Upcoming',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _showUpcoming ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showUpcoming = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: !_showUpcoming ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  'Calendar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_showUpcoming ? Colors.white : AppColors.textSecondary,
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

  Widget _buildTodayShifts(List<Shift> todayShifts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.today, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Today\'s Shifts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (todayShifts.isEmpty)
          _buildEmptyState('No shifts scheduled for today', Icons.free_breakfast)
        else
          ...todayShifts.map((shift) => _buildShiftCard(shift, isToday: true)),
      ],
    );
  }

  Widget _buildUpcomingShifts(List<Shift> upcomingShifts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Upcoming Shifts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (upcomingShifts.isEmpty)
          _buildEmptyState('No upcoming shifts', Icons.event_available)
        else
          ...upcomingShifts.take(5).map((shift) => _buildShiftCard(shift)),
      ],
    );
  }

  Widget _buildCalendarView(List<Shift> shifts) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: TableCalendar<Shift>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: (day) => _getShiftsForDate(shifts, day),
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: AppColors.error),
            holidayTextStyle: TextStyle(color: AppColors.error),
            selectedDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayShifts(List<Shift> dayShifts) {
    final selectedDate = _selectedDay ?? DateTime.now();
    final isToday = isSameDay(selectedDate, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isToday 
            ? 'Today\'s Shifts' 
            : 'Shifts for ${_formatDate(selectedDate)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (dayShifts.isEmpty)
          _buildEmptyState(
            isToday ? 'No shifts today' : 'No shifts on this date',
            Icons.event_available,
          )
        else
          ...dayShifts.map((shift) => _buildShiftCard(shift, isToday: isToday)),
      ],
    );
  }

  Widget _buildShiftCard(Shift shift, {bool isToday = false}) {
    final shiftColor = _getShiftColor(shift.shiftType);
    final shiftIcon = _getShiftIcon(shift.shiftType);
    final timeRange = _getShiftTimeRange(shift.shiftType);

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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: shiftColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                shiftIcon,
                color: shiftColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        shift.shiftType,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
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
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeRange,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _formatDate(DateTime.parse(shift.date)),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: shiftColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                shift.id,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
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
            'Error loading shifts',
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
                ref.read(shiftProvider.notifier).fetchShifts(user.id);
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

  // Helper methods
  List<Shift> _getUpcomingShifts(List<Shift> shifts) {
    final now = DateTime.now();
    return shifts.where((shift) {
      final shiftDate = DateTime.parse(shift.date);
      return shiftDate.isAfter(now) || isSameDay(shiftDate, now);
    }).toList()
      ..sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
  }

  List<Shift> _getTodayShifts(List<Shift> shifts) {
    final today = DateTime.now();
    return shifts.where((shift) {
      final shiftDate = DateTime.parse(shift.date);
      return isSameDay(shiftDate, today);
    }).toList();
  }

  List<Shift> _getThisWeekShifts(List<Shift> shifts) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return shifts.where((shift) {
      final shiftDate = DateTime.parse(shift.date);
      return shiftDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             shiftDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  List<Shift> _getCompletedShifts(List<Shift> shifts) {
    final now = DateTime.now();
    return shifts.where((shift) {
      final shiftDate = DateTime.parse(shift.date);
      return shiftDate.isBefore(now) && !isSameDay(shiftDate, now);
    }).toList();
  }

  List<Shift> _getShiftsForDate(List<Shift> shifts, DateTime? date) {
    if (date == null) return [];
    return shifts.where((shift) {
      final shiftDate = DateTime.parse(shift.date);
      return isSameDay(shiftDate, date);
    }).toList();
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

  String _getShiftTimeRange(String shiftType) {
    switch (shiftType.toLowerCase()) {
      case 'morning':
        return '6:00 AM - 2:00 PM';
      case 'afternoon':
        return '2:00 PM - 10:00 PM';
      case 'evening':
        return '6:00 PM - 2:00 AM';
      case 'night':
        return '10:00 PM - 6:00 AM';
      default:
        return 'Time TBD';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
