import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants/api_endpoints.dart';
import 'package:flutter_application/models/register_model.dart';
import 'package:flutter_application/shared/error_dialog.dart';
import 'package:flutter_application/shared/submit_button.dart';
import 'package:flutter_application/shared/text_fields.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      final registerData = RegisterModel(
        name: _nameController.text,
        password: _passwordController.text,
        email: _emailController.text,
        phone: _phoneNumberController.text,
        address: _addressController.text,
      );
      var result = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(registerData.toJson()),
      );

      if (result.statusCode >= 200 && result.statusCode <= 299) {
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        final errorData = jsonDecode(result.body);
        //final int statusCode = errorData['status'];
        final String title = errorData['message'] ?? "Произошла ошибка. ";

        if (!mounted) return;

        errorDialog(
          context: context,
          statusCode: result.statusCode,
          description: title,
          color: Colors.green,
        );
      }
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Регистрация",
              style: TextStyle(
                fontSize: 36,
                color: Color.fromRGBO(56, 56, 56, .9),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    userNameTextField(nameController: _nameController),
                    const SizedBox(height: 10),
                    emailTextField(emailController: _emailController),
                    const SizedBox(height: 10),
                    passwordTextField(passwordController: _passwordController),
                    const SizedBox(height: 10),
                    phoneNumberField(
                      phoneNumberController: _phoneNumberController,
                    ),
                    const SizedBox(height: 10),
                    textField(textController: _addressController),
                    const SizedBox(height: 10),
                    submitButton(
                      context: context,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      title: "Принять",
                      method: submitForm,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                text: "У Вас уже есть аккаунт? ",
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(
                    text: "Авторизоваться",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pop();
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
