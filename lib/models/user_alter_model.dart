class UserAlterModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final List<String>? role;

  const UserAlterModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
  });

  factory UserAlterModel.fromJson(Map<String, dynamic> json) {
    return UserAlterModel(
      id: json['id'] as String,
      name: json['userName'] as String,
      email: json['email'] as String,
      phone: json['phoneNumber'] as String?,
      role: json['role'] != null ? List<String>.from(json['role']) : null,
    );
  }
}
