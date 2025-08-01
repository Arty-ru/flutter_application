import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/constants/api_endpoints.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/constants/border_styles.dart';
import 'package:flutter_application/constants/token_handler.dart';
import 'package:flutter_application/services/role_check.dart';
import 'package:flutter_application/shared/custom_appbar.dart';
import 'package:flutter_application/shared/error_dialog.dart';
import 'package:flutter_application/shared/submit_button.dart';
import 'package:http/http.dart' as http;

class AddRole extends StatefulWidget {
  const AddRole({super.key});

  @override
  State<AddRole> createState() => _AddRoleState();
}

class _AddRoleState extends State<AddRole> {
  final TextEditingController _roleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    RoleCheck().checkAdminRole(context);
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      var result = await http.post(
        Uri.parse(ApiEndpoints.adminRolesCrud),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${TokenHandler().getToken()}',
        },
        body: jsonEncode(_roleController.text),
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
        title: "Новая роль",
        color: AppColors.adminPage,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Имя роли",
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
                  TextFormField(
                    controller: _roleController,
                    decoration: InputDecoration(
                      labelText: 'Роль',
                      floatingLabelStyle: const TextStyle(
                        color: AppColors.adminPage,
                      ),
                      border: BorderStyles.border,
                      focusedBorder: BorderStyles.focusedBorder,
                      errorBorder: BorderStyles.errorBorder,
                      focusedErrorBorder: BorderStyles.focusedErrorBorder,
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите имя роли';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  submitButton(
                    context: context,
                    backgroundColor: AppColors.adminPage,
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
