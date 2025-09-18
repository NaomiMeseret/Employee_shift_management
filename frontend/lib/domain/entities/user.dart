class User {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;
  final String? phone;
  final String? position;
  final String status;

  User({
    required this.id, 
    required this.name, 
    required this.email, 
    required this.isAdmin,
    this.phone,
    this.position,
    required this.status,
  });
} 