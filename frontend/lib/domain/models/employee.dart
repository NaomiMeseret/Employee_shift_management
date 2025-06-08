class Employee {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String position;
  final String status;
  final bool isAdmin;
  final String? profilePicture;
  final String password;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.status,
    required this.isAdmin,
    this.profilePicture,
    required this.password,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      position: json['position'] as String? ?? '',
      status: json['status'] as String? ?? '',
      isAdmin: json['isAdmin'] as bool? ?? false,
      profilePicture: json['profilePicture'] as String?,
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'status': status,
      'isAdmin': isAdmin,
      'profilePicture': profilePicture,
      'password': password,
    };
  }

  Employee copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? position,
    String? status,
    bool? isAdmin,
    String? profilePicture,
    String? password,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      status: status ?? this.status,
      isAdmin: isAdmin ?? this.isAdmin,
      profilePicture: profilePicture ?? this.profilePicture,
      password: password ?? this.password,
    );
  }
} 