import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/admin_providers.dart';
import '../../../domain/models/employee.dart';
import '../../../config/app_theme.dart';
import '../../widgets/enhanced_employee_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/admin_navigation_bar.dart';
import '../../widgets/admin_header.dart';
import 'employee_form.dart';

const Color kPrimaryGreen = Color(0xFF2E5D47);

class AdminEmployeeScreen extends ConsumerStatefulWidget {
  const AdminEmployeeScreen({super.key});

  @override
  ConsumerState<AdminEmployeeScreen> createState() => _AdminEmployeeScreenState();
}

class _AdminEmployeeScreenState extends ConsumerState<AdminEmployeeScreen> {
  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/admin');
        return false;
      },
      child: Scaffold(
        appBar: const AdminHeader(
          title: 'Employee Management',
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.person),
            ),
          ],
        ),
        body: Column(
          children: [
            const AdminNavigationBar(currentIndex: 1),
            employeesAsync.when(
              data: (employees) => SectionHeader(
                title: 'Employee Management',
                subtitle: 'Manage your team members and their information',
                icon: Icons.people,
                color: AppColors.primary,
                itemCount: employees.length,
                actionText: 'Add Member',
                actionIcon: Icons.add,
                onActionPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployeeForm(),
                    ),
                  );
                },
              ),
              loading: () => SectionHeader(
                title: 'Employee Management',
                subtitle: 'Loading employees...',
                icon: Icons.people,
                color: AppColors.primary,
                actionText: 'Add Member',
                actionIcon: Icons.add,
                onActionPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployeeForm(),
                    ),
                  );
                },
              ),
              error: (error, stack) => SectionHeader(
                title: 'Employee Management',
                subtitle: 'Error loading employees',
                icon: Icons.people,
                color: AppColors.error,
                actionText: 'Add Member',
                actionIcon: Icons.add,
                onActionPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployeeForm(),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: employeesAsync.when(
                data: (employees) => employees.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.refresh(employeesProvider);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: employees.length,
                          itemBuilder: (context, index) {
                            final employee = employees[index];
                            return EnhancedEmployeeCard(
                              employee: employee,
                              onViewDetails: () => _showEmployeeDetails(context, employee),
                              onEdit: () => _editEmployee(context, employee),
                              onDelete: () => _showDeleteConfirmation(context, employee, ref),
                            );
                          },
                        ),
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
                error: (error, stackTrace) => _buildErrorState(error.toString(), ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Employees Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first team member',
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
                  builder: (context) => const EmployeeForm(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Employee'),
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

  Widget _buildErrorState(String error, WidgetRef ref) {
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

  void _showEmployeeDetails(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Employee Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', employee.name),
            _buildDetailRow('ID', employee.id),
            _buildDetailRow('Email', employee.email),
            _buildDetailRow('Phone', employee.phone),
            _buildDetailRow('Position', employee.position),
            _buildDetailRow('Status', employee.status),
            _buildDetailRow('Admin', employee.isAdmin ? 'Yes' : 'No'),
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

  void _editEmployee(BuildContext context, Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeForm(employee: employee),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Employee employee, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(employeesProvider.notifier).deleteEmployee(employee.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${employee.name} deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete employee: $e')),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search employees...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildEmployeeList(BuildContext context, List<Employee> employees) {
    return ListView.builder(
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                employee.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(employee.name),
            subtitle: Text(employee.position),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(employee.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    employee.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showEmployeeOptions(context, employee),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeForm(employee: employee),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'on leave':
        return Colors.orange;
      case 'terminated':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showEmployeeOptions(BuildContext context, Employee employee) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Employee'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmployeeForm(employee: employee),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Employee', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, employee, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

}