import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/accounts/login.dart';
import 'package:flutter_application/constants/api_endpoints.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/constants/token_handler.dart';
import 'package:flutter_application/models/change_password_model.dart';
import 'package:flutter_application/services/role_check.dart';
import 'package:flutter_application/shared/custom_appbar.dart';
import 'package:flutter_application/shared/error_dialog.dart';
import 'package:flutter_application/shared/submit_button.dart';
import 'package:flutter_application/shared/text_fields.dart';
import 'package:http/http.dart' as http;

class ChangeUserPassword extends StatefulWidget {
  final String email;
  const ChangeUserPassword({super.key, required this.email});

  @override
  State<ChangeUserPassword> createState() => _ChangeUserPasswordState();
}

class _ChangeUserPasswordState extends State<ChangeUserPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    RoleCheck().checkUserRole(context);
    _emailController.text = widget.email;
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final changePassword = ChangePasswordModel(
        email: _emailController.text,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      var result = await http.put(
        Uri.parse(ApiEndpoints.userChangePassword),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${TokenHandler().getToken()}',
        },
        body: json.encode(changePassword.toJson()),
      );

      if (result.statusCode >= 200 && result.statusCode <= 299) {
        TokenHandler().clearToken();

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        var errorBody = jsonDecode(result.body);
        final error = errorBody['message'] ?? "Произошла ошибка.";

        if (!mounted) return;

        errorDialog(
          context: context,
          statusCode: result.statusCode,
          description: error,
          color: Colors.green,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: "Изменить пароль",
        color: AppColors.userPage,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Введите данные пользователя",
            style: TextStyle(
              color: Color.fromRGBO(56, 56, 56, .9),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  emailTextField(
                    emailController: _emailController,
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  passwordTextField(
                    passwordController: _currentPasswordController,
                    label: "Текущий пароль",
                  ),
                  const SizedBox(height: 20),
                  passwordTextField(
                    passwordController: _newPasswordController,
                    label: "Новый пароль",
                  ),
                  const SizedBox(height: 20),
                  submitButton(
                    context: context,
                    backgroundColor: AppColors.userPage,
                    textColor: Colors.white,
                    title: "Принять",
                    method: submitForm,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
