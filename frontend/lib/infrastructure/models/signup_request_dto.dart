class SignupRequestDto {
  final String name;
  final String email;
  final String password;
  final String id;
  final String? profilePicture;
  final String? phone;
  final String? position;
  final String? shift;
  final String? status;
  final bool? isAdmin;

  SignupRequestDto({
    required this.name,
    required this.email,
    required this.password,
    required this.id,
    this.profilePicture,
    this.phone,
    this.position,
    this.shift,
    this.status,
    this.isAdmin,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'id': id,
    'profilePicture': profilePicture ?? '',
    'phone': phone ?? '0000000000',
    'position': position ?? 'Employee',
    'shift': shift ?? 'Morning',
    'status': status ?? 'active',
    'isAdmin': isAdmin ?? false,
  };
} 