class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final List<String>? role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['userName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      role: json['role'] != null ? List<String>.from(json['role']) : null,
    );
  }
}
