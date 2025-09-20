import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_navigation_bar.dart';
import '../../widgets/admin_header.dart';
import '../../widgets/enhanced_shift_card.dart';
import '../../widgets/section_header.dart';
import '../../../application/providers/admin_providers.dart';
import '../../../config/app_theme.dart';
import '../../../domain/models/shift.dart';
import '../../../domain/models/employee.dart';
import 'assign_shift_form.dart';

const Color kPrimaryGreen = Color(0xFF2E5D47);

class AdminShiftScreen extends ConsumerStatefulWidget {
  const AdminShiftScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminShiftScreen> createState() => _AdminShiftScreenState();
}

class _AdminShiftScreenState extends ConsumerState<AdminShiftScreen> {
  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);
    final shiftsAsync = ref.watch(shiftsProvider);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/admin');
        return false;
      },
      child: Scaffold(
        appBar: const AdminHeader(title: 'Shift Management'),
        body: Column(
          children: [
            const AdminNavigationBar(currentIndex: 2),
            shiftsAsync.when(
              data: (shifts) => SectionHeader(
                title: 'Shift Management',
                subtitle: 'Manage employee shifts and schedules',
                icon: Icons.schedule,
                color: AppColors.info,
                itemCount: shifts.length,
                actionText: 'Assign Shift',
                actionIcon: Icons.add,
                onActionPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AssignShiftForm(),
                    ),
                  );
                },
              ),
              loading: () => SectionHeader(
                title: 'Shift Management',
                subtitle: 'Loading shifts...',
                icon: Icons.schedule,
                color: AppColors.info,
                actionText: 'Assign Shift',
                actionIcon: Icons.add,
                onActionPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AssignShiftForm(),
                    ),
                  );
                },
              ),
              error: (error, stack) => SectionHeader(
                title: 'Shift Management',
                subtitle: 'Error loading shifts',
                icon: Icons.schedule,
                color: AppColors.error,
                actionText: 'Assign Shift',
                actionIcon: Icons.add,
                onActionPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AssignShiftForm(),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: employeesAsync.when(
                data: (employees) => shiftsAsync.when(
                  data: (shifts) {
                    if (shifts.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    
                    final employeeMap = {for (var e in employees) e.id: e.name};
                    
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.refresh(shiftsProvider);
                        ref.refresh(employeesProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: shifts.length,
                        itemBuilder: (context, index) {
                          final shift = shifts[index];
                          final employeeName = _getEmployeeName(shift.employeeId, employeeMap);
                          
                          return EnhancedShiftCard(
                            shift: shift,
                            employeeName: employeeName,
                            onViewDetails: () => _showShiftDetails(context, shift, employeeName),
                            onEdit: () => _editShift(context, shift),
                            onDelete: () => _showDeleteConfirmation(context, shift, ref),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading shifts...'),
                      ],
                    ),
                  ),
                  error: (error, stackTrace) => _buildErrorState(error.toString()),
                ),
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading employees...'),
                    ],
                  ),
                ),
                error: (error, stackTrace) => _buildErrorState(error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.schedule_outlined,
              size: 64,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Shifts Assigned',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by assigning shifts to your employees',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AssignShiftForm(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Assign First Shift'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              ref.refresh(shiftsProvider);
              ref.refresh(employeesProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getEmployeeName(int employeeId, Map<String, String> employeeMap) {
    // Try to get name by string ID first, then by int ID
    return employeeMap[employeeId.toString()] ?? 
           employeeMap[employeeId] ?? 
           'Employee ID: $employeeId';
  }

  void _showShiftDetails(BuildContext context, Shift shift, String employeeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shift Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Employee', employeeName),
            _buildDetailRow('Shift Type', shift.shiftType),
            _buildDetailRow('Date', shift.date),
            _buildDetailRow('Status', shift.status ?? 'Active'),
            if (shift.notes != null && shift.notes!.isNotEmpty)
              _buildDetailRow('Notes', shift.notes!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editShift(BuildContext context, Shift shift) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignShiftForm(
          key: ValueKey('edit_shift_${shift.id}'),
          shift: shift,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Shift shift, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shift'),
        content: const Text('Are you sure you want to delete this shift? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(shiftsProvider.notifier).deleteShift(shift.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Shift deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete shift: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}