import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/admin_area/admin_main_page.dart';
import 'package:flutter_application/constants/api_endpoints.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/constants/border_styles.dart';
import 'package:flutter_application/constants/token_handler.dart';
import 'package:flutter_application/models/change_role_model.dart';
import 'package:flutter_application/models/role_model.dart';
import 'package:flutter_application/services/role_check.dart';
import 'package:flutter_application/shared/custom_appbar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/shared/error_dialog.dart';
import 'package:flutter_application/shared/submit_button.dart';
import 'package:flutter_application/shared/text_fields.dart';

class AssignRole extends StatefulWidget {
  final String email;
  const AssignRole({super.key, required this.email});

  @override
  State<AssignRole> createState() => _AssignRoleState();
}

class _AssignRoleState extends State<AssignRole> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedItem;
  List<RoleModel> roles = [];

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  @override
  void initState() {
    super.initState();
    RoleCheck().checkAdminRole(context);
    _emailController.text = widget.email;
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    final result = await http.get(
      Uri.parse(ApiEndpoints.adminRolesCrud),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${TokenHandler().getToken()}',
      },
    );

    if (result.statusCode >= 200 && result.statusCode <= 299) {
      final List<dynamic> jsonData = json.decode(result.body);
      setState(() {
        roles = jsonData.map((role) => RoleModel.fromJson(role)).toList();
      });
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

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedItem == null) {
        return;
      }

      final changeRole = ChangeRoleModel(
        userEmail: _emailController.text,
        newRole: _selectedItem!,
      );

      final result = await http.post(
        Uri.parse(ApiEndpoints.adminChangeUserRole),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${TokenHandler().getToken()}',
        },
        body: json.encode(changeRole.toJson()),
      );

      if (result.statusCode >= 200 && result.statusCode <= 299) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminMainPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        var errorBody;
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
        title: "Выдать роль",
        color: AppColors.adminPage,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text("Выберите пользователя"),
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
                  DropdownButtonFormField<String>(
                    decoration:
                        BorderStyles.roleDropdownButtonFormFieldInputDecoration,
                    value: _selectedItem,
                    isExpanded: true,
                    items:
                        roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role.name,
                            child: Text(role.name),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedItem = newValue;
                      });
                    },
                    validator:
                        (value) =>
                            value == null ? 'Пожалуйста, выберите роль' : null,
                  ),
                  const SizedBox(height: 20),
                  submitButton(
                    context: context,
                    backgroundColor: AppColors.adminPage,
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
