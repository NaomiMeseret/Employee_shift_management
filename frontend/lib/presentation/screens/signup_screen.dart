import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../widgets/form_field_wrapper.dart';
import '../widgets/custom_button.dart';
import '../states/auth_notifier.dart';
import '../../application/services/validation_service.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _employeeIdController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Join ShiftMaster',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your employee account',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                FormFieldWrapper(
                  label: 'Full Name',
                  child: CustomTextFormField(
                    controller: _nameController,
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person),
                    validator: ValidationService.validateName,
                  ),
                ),
                const SizedBox(height: 16),

                FormFieldWrapper(
                  label: 'Employee ID',
                  child: CustomTextFormField(
                    controller: _employeeIdController,
                    hintText: 'Enter your employee ID',
                    prefixIcon: const Icon(Icons.badge),
                    keyboardType: TextInputType.number,
                    validator: ValidationService.validateEmployeeId,
                  ),
                ),
                const SizedBox(height: 16),

                FormFieldWrapper(
                  label: 'Email Address',
                  child: CustomTextFormField(
                    controller: _emailController,
                    hintText: 'Enter your email address',
                    prefixIcon: const Icon(Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: ValidationService.validateEmail,
                  ),
                ),
                const SizedBox(height: 16),

                FormFieldWrapper(
                  label: 'Phone Number',
                  child: CustomTextFormField(
                    controller: _phoneController,
                    hintText: 'Enter your phone number',
                    prefixIcon: const Icon(Icons.phone),
                    keyboardType: TextInputType.phone,
                    validator: ValidationService.validatePhone,
                  ),
                ),
                const SizedBox(height: 16),

                FormFieldWrapper(
                  label: 'Position',
                  child: CustomTextFormField(
                    controller: _positionController,
                    hintText: 'Enter your job position',
                    prefixIcon: const Icon(Icons.work),
                    validator: (value) => ValidationService.validateName(value),
                  ),
                ),
                const SizedBox(height: 16),

                FormFieldWrapper(
                  label: 'Password',
                  child: CustomTextFormField(
                    controller: _passwordController,
                    hintText: 'Create a strong password',
                    prefixIcon: const Icon(Icons.lock),
                    obscureText: true,
                    validator: ValidationService.validatePassword,
                  ),
                ),
                const SizedBox(height: 16),

                FormFieldWrapper(
                  label: 'Confirm Password',
                  child: CustomTextFormField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscureText: true,
                    validator: (value) => ValidationService.validatePasswordConfirmation(
                      value,
                      _passwordController.text,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Error Message
                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Sign Up Button
                CustomButton(
                  text: 'Create Account',
                  onPressed: authState.isLoading ? null : _handleSignup,
                  isLoading: authState.isLoading,
                  type: ButtonType.primary,
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Terms and Conditions
                Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    
    try {
      await authNotifier.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        id: _employeeIdController.text.trim(),
        phone: _phoneController.text.trim(),
        position: _positionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
            'Registration successful! Please wait for admin approval.',
          )),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }
}
