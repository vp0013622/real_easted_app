class UsersModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String password;
  final String role;
  final String createdByUserId;
  final String updatedByUserId;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;

  UsersModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.password,
    required this.role,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deserialize from JSON
  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
      createdByUserId: json['createdByUserId'] ?? '',
      updatedByUserId: json['updatedByUserId'] ?? '',
      published: json['published'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'password': password,
      'role': role,
      'createdByUserId': createdByUserId,
      'updatedByUserId': updatedByUserId,
      'published': published,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
