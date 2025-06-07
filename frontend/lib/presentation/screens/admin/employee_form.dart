import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/employee.dart';
import '../../../application/providers/admin_providers.dart';

class EmployeeForm extends ConsumerStatefulWidget {
  final Employee? employee;

  const EmployeeForm({
    super.key,
    this.employee,
  });

  @override
  ConsumerState<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends ConsumerState<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _passwordController;
  String _status = 'active';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.employee?.id != null ? widget.employee!.id.toString() : '');
    _nameController = TextEditingController(text: widget.employee?.name);
    _emailController = TextEditingController(text: widget.employee?.email);
    _phoneController = TextEditingController(text: widget.employee?.phone);
    _positionController = TextEditingController(text: widget.employee?.position);
    _passwordController = TextEditingController();
    if (widget.employee != null) {
      _status = widget.employee!.status.toLowerCase();
      _isAdmin = widget.employee!.isAdmin;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final employee = Employee(
        id: int.tryParse(_idController.text) ?? 0,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        position: _positionController.text,
        status: _status,
        isAdmin: _isAdmin,
        profilePicture: widget.employee?.profilePicture,
        password: _passwordController.text,
      );

      try {
        if (widget.employee == null) {
          await ref.read(employeesProvider.notifier).addEmployee(employee);
        } else {
          await ref.read(employeesProvider.notifier).updateEmployee(employee);
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an employee ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Employee ID must be a number';
                  }
                  return null;
                },
                enabled: widget.employee == null, // Prevent editing ID on update
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a position';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (widget.employee == null) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'on leave', child: Text('On Leave')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Admin Access'),
                value: _isAdmin,
                onChanged: (value) {
                  setState(() {
                    _isAdmin = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.employee == null ? 'Add Employee' : 'Update Employee',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 