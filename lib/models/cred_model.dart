class CredModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String password;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CredModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.password,
    required this.createdAt,
    this.updatedAt,
  });

  factory CredModel.fromMap(Map<String, dynamic> map) {
    return CredModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'],
      password: map['password'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CredModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CredModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}