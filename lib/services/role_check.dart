import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_application/accounts/login.dart';
import 'package:flutter_application/constants/token_handler.dart';

class RoleCheck {
  void checkAdminRole(BuildContext context) {
    final decodedToken = JwtDecoder.decode(TokenHandler().getToken());
    String role =
        decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

    if (role != "Admin" || role.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      });
    }
  }

  void checkUserRole(BuildContext context) {
    final decodedToken = JwtDecoder.decode(TokenHandler().getToken());
    String role =
        decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

    if (role != "User" || role.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      });
    }
  }

  void checkStaffRole(BuildContext context) {
    final decodedToken = JwtDecoder.decode(TokenHandler().getToken());
    String role =
        decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

    if (role != "Staff" || role.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      });
    }
  }
}
