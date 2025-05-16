import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/constants/api_endpoints.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/constants/token_handler.dart';
import 'package:flutter_application/models/user_alter_model.dart';
import 'package:flutter_application/services/role_check.dart';
import 'package:flutter_application/shared/custom_appbar.dart';
import 'package:flutter_application/shared/error_dialog.dart';
import 'package:flutter_application/shared/submit_button.dart';
import 'package:flutter_application/shared/text_fields.dart';

class EditProfile extends StatefulWidget {
  final String email;
  const EditProfile({super.key, required this.email});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    RoleCheck().checkAdminRole(context);
    getAdminInfo(widget.email);
  }

  Future<void> getAdminInfo(String email) async {
    var result = await http.post(
      Uri.parse(ApiEndpoints.adminInfoGetAndUpdate),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        // ignore: await_only_futures
        'Authorization': 'Bearer ${await TokenHandler().getToken()}',
      },
      body: json.encode(email),
    );
    if (result.statusCode >= 200 && result.statusCode <= 299) {
      final jsonData = json.decode(result.body);
      final user = UserAlterModel.fromJson(jsonData);
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneNumberController.text = user.phone ?? "";
        _addressController.text = user.address ?? "";
      });
    } else {
      final error =
          result.body.isNotEmpty
              ? jsonDecode(result.body)['message'] ?? "Произошла ошибка."
              : "Пользователей не найдено.";

      if (!mounted) return;

      errorDialog(
        context: context,
        statusCode: result.statusCode,
        description: error,
        color: Colors.green,
      );
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      var result = await http.put(
        Uri.parse(ApiEndpoints.adminInfoGetAndUpdate),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${TokenHandler().getToken()}',
        },
        body: jsonEncode({
          "name": _nameController.text,
          "email": _emailController.text,
          "phone": _phoneNumberController.text,
          "address": _addressController.text,
        }),
      );

      if (result.statusCode >= 200 && result.statusCode <= 299) {
        if (!mounted) return;
        Navigator.of(context).pop();
      } else {
        // ignore: prefer_typing_uninitialized_variables
        var errorBody;
        // ignore: prefer_typing_uninitialized_variables
        var error;
        if (result.body.isNotEmpty) {
          errorBody = jsonDecode(result.body);
          error = errorBody['message'] ?? "Произошла ошибка. ";
        } else {
          error = "Пользователей не найдено.";
        }

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
        title: "Информация о пользователе",
        color: AppColors.adminPage,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Детали",
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
                  userNameTextField(
                    nameController: _nameController,
                    readOnly: false,
                  ),
                  const SizedBox(height: 20),
                  phoneNumberField(
                    phoneNumberController: _phoneNumberController,
                  ),
                  const SizedBox(height: 20),
                  textField(textController: _addressController),
                  const SizedBox(height: 20),
                  submitButton(
                    context: context,
                    backgroundColor: AppColors.adminPage,
                    textColor: Colors.white,
                    title: "Обновить",
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
