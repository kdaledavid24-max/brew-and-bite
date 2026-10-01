/// User model representing a customer or admin
class UserModel {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role;
  final String? address;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.address,
    required this.createdAt,
  });

  /// Convert UserModel to a Map for local storage (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create UserModel from a stored Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      address: map['address'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? role,
    String? address,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role ?? this.role,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
