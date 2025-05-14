import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/constants/api_endpoints.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/constants/token_handler.dart';
import 'package:flutter_application/models/register_model.dart';
import 'package:flutter_application/services/role_check.dart';
import 'package:flutter_application/shared/custom_appbar.dart';
import 'package:flutter_application/shared/error_dialog.dart';
import 'package:flutter_application/shared/submit_button.dart';
import 'package:flutter_application/shared/text_fields.dart';
import 'package:http/http.dart' as http;

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    RoleCheck().checkAdminRole(context);
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final registerData = RegisterModel(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneNumberController.text,
      );

      var result = await http.post(
        Uri.parse(ApiEndpoints.adminUsersCrud),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${TokenHandler().getToken()}',
        },
        body: jsonEncode(registerData.toJson()),
      );

      if (result.statusCode >= 200 && result.statusCode <= 299) {
        if (!mounted) return;
        Navigator.of(context).pop();
      } else {
        var errorBody;
        if (result.body.isNotEmpty) {
          errorBody = jsonDecode(result.body);
        }
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
        title: "Новый пользователь",
        color: AppColors.adminPage,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Информация о пользователе",
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
                  userNameTextField(nameController: _nameController),
                  const SizedBox(height: 20),
                  emailTextField(emailController: _emailController),
                  const SizedBox(height: 20),
                  passwordTextField(passwordController: _passwordController),
                  const SizedBox(height: 20),
                  phoneNumberField(
                    phoneNumberController: _phoneNumberController,
                  ),
                  const SizedBox(height: 20),
                  submitButton(
                    context: context,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    title: "Добавить",
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
