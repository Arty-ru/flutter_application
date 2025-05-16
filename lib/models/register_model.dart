// ignore: unused_import
import 'package:flutter_application/admin_area/add_role.dart';

class RegisterModel {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? address;

  const RegisterModel({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
    };
  }
}
