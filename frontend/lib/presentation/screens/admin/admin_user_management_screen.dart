import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/user.dart';
import '../../../infrastructure/repositories_impl/auth_repository_impl.dart';
import '../../../infrastructure/services/admin_api_service.dart';
import '../../../config/app_config.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_app_bar.dart';
import '../../../config/app_theme.dart';

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends ConsumerState<AdminUserManagementScreen> {
  List<User> pendingUsers = [];
  bool isLoading = true;
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  late final AdminApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = AdminApiService(baseUrl: AppConfig.apiBaseUrl);
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() => isLoading = true);
    try {
      final pendingUsersData = await _apiService.getPendingUsers();
      final users = pendingUsersData.map((userData) => User(
        id: userData['id']?.toString() ?? '',
        name: userData['name']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        isAdmin: userData['isAdmin'] ?? false,
        phone: userData['phone']?.toString(),
        position: userData['position']?.toString(),
        status: userData['status']?.toString() ?? 'pending',
      )).toList();
      
      setState(() {
        pendingUsers = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load pending users: $e')),
        );
      }
    }
  }

  Future<void> _approveUser(User user) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call actual API
      await _apiService.approveUser(user.id);

      if (mounted) {
        Navigator.pop(context); 
        setState(() {
          pendingUsers.removeWhere((u) => u.id == user.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} has been approved')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve user: $e')),
        );
      }
    }
  }

  Future<void> _rejectUser(User user) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call actual API
      await _apiService.rejectUser(user.id);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        setState(() {
          pendingUsers.removeWhere((u) => u.id == user.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} has been rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject user: $e')),
        );
      }
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', user.name),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Employee ID', user.id),
              _buildDetailRow('Phone', user.phone ?? 'Not provided'),
              _buildDetailRow('Position', user.position ?? 'Not provided'),
              _buildDetailRow('Status', user.status),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          CustomButton(
            text: 'Reject',
            onPressed: () {
              Navigator.pop(context);
              _showRejectConfirmation(user);
            },
            type: ButtonType.outline,
          ),
          const SizedBox(width: 8),
          CustomButton(
            text: 'Approve',
            onPressed: () {
              Navigator.pop(context);
              _approveUser(user);
            },
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showRejectConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject User'),
        content: Text('Are you sure you want to reject ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Reject',
            onPressed: () {
              Navigator.pop(context);
              _rejectUser(user);
            },
            type: ButtonType.outline,
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
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'User Management',
        showBackButton: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPendingUsers,
              child: pendingUsers.isEmpty
                  ? _buildEmptyState()
                  : _buildUserList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Pending Users',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All user registrations have been processed',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Refresh',
            onPressed: _loadPendingUsers,
            type: ButtonType.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingUsers.length,
      itemBuilder: (context, index) {
        final user = pendingUsers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(user.email),
                const SizedBox(height: 2),
                Text(
                  'ID: ${user.id} • ${user.position ?? 'No position'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pending Approval',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _showUserDetails(user);
                    break;
                  case 'approve':
                    _approveUser(user);
                    break;
                  case 'reject':
                    _showRejectConfirmation(user);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'approve',
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Approve'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reject',
                  child: Row(
                    children: [
                      Icon(Icons.close, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Reject'),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _showUserDetails(user),
          ),
        );
      },
    );
  }
}
