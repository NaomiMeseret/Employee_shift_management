import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/admin_providers.dart';
import '../../../domain/models/shift.dart';

const Color kPrimaryGreen = Color(0xFF2E5D47);

class AssignShiftForm extends ConsumerStatefulWidget {
  final Shift? shift; // If provided, we're editing an existing shift

  const AssignShiftForm({Key? key, this.shift}) : super(key: key);

  @override
  ConsumerState<AssignShiftForm> createState() => _AssignShiftFormState();
}

class _AssignShiftFormState extends ConsumerState<AssignShiftForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmployeeId;
  String? _selectedShiftType;
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.shift != null) {
      _selectedEmployeeId = widget.shift!.employeeId.toString();
      _selectedShiftType = widget.shift!.shiftType;
      final dateVal = widget.shift!.date;
      if (dateVal.isNotEmpty) {
        try {
          _selectedDate = DateTime.tryParse(dateVal);
          if (_selectedDate == null) {
            // Try parsing date in a different format if the default parsing fails
            _selectedDate = DateTime.tryParse(dateVal.split(' ')[0]);
          }
        } catch (e) {
          debugPrint('Error parsing date: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Validate form
    if (_selectedEmployeeId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please select an employee.';
      });
      return;
    }
    
    if (_selectedShiftType == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please select a shift type.';
      });
      return;
    }
    
    if (_selectedDate == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please select a date.';
      });
      return;
    }
    try {
      // Format date as YYYY-MM-DD
      final formattedDate = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      
      if (widget.shift == null) {
        // Creating new shift
        await ref.read(shiftsProvider.notifier).addShift(
          Shift(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            employeeId: int.tryParse(_selectedEmployeeId!) ?? 0,
            shiftType: _selectedShiftType!,
            date: formattedDate,
          ),
        );
      } else {
        // Updating existing shift
        await ref.read(shiftsProvider.notifier).updateShift(
          Shift(
            id: widget.shift!.id,
            employeeId: int.tryParse(_selectedEmployeeId!) ?? 0,
            shiftType: _selectedShiftType!,
            date: formattedDate,
          ),
        );
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.shift == null 
              ? 'Shift assigned successfully' 
              : 'Shift updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shift == null ? 'Assign Shift' : 'Edit Shift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              employeesAsync.when(
                data: (employees) => DropdownButtonFormField<String>(
                  value: _selectedEmployeeId,
                  decoration: const InputDecoration(
                    labelText: 'Employee',
                    border: OutlineInputBorder(),
                  ),
                  items: employees.map<DropdownMenuItem<String>>((e) {
                    return DropdownMenuItem(
                      value: e.id.toString(),
                      child: Text(e.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEmployeeId = value;
                    });
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Text('Error: $error'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedShiftType,
                decoration: const InputDecoration(
                  labelText: 'Shift Type',
                  border: OutlineInputBorder(),
                ),
                items: ['morning', 'afternoon', 'night']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedShiftType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      hintText: 'Select date',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: _selectedDate == null
                          ? ''
                          : _selectedDate!.toLocal().toString().split(' ')[0],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _submitForm,
                      child: Text(widget.shift == null ? 'Assign Shift' : 'Update Shift'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
} 