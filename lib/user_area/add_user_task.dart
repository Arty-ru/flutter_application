import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants/api_endpoints.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/constants/border_styles.dart';
import 'package:flutter_application/constants/token_handler.dart';
import 'package:flutter_application/models/task_model.dart';
import 'package:flutter_application/models/user_alter_model.dart';
import 'package:flutter_application/services/role_check.dart';
import 'package:flutter_application/shared/custom_appbar.dart';
import 'package:flutter_application/shared/error_dialog.dart';
import 'package:flutter_application/shared/submit_button.dart';
import 'package:flutter_application/shared/text_fields.dart';
import 'package:http/http.dart' as http;

class AddUserTask extends StatefulWidget {
  final String email;
  const AddUserTask({super.key, required this.email});

  @override
  State<AddUserTask> createState() => _AddUserState();
}

class _AddUserState extends State<AddUserTask> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedItem;
  final items = ["New", "In Progress", "Completed"];

  @override
  void initState() {
    super.initState();
    RoleCheck().checkUserRole(context);
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedItem == null) {
        return;
      }
      var user = UserAlterModel(
        id: "0",
        name: "",
        email: "",
        phone: "",
        address: "",
        role: <String>[],
      );
      var admin = await http.post(
        Uri.parse(ApiEndpoints.userInfoRead),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await TokenHandler().getToken()}',
        },
        body: json.encode(widget.email),
      );
      if (admin.statusCode >= 200 && admin.statusCode <= 299) {
        final jsonData = json.decode(admin.body);
        user = UserAlterModel.fromJson(jsonData);
      } else {
        final error =
            admin.body.isNotEmpty
                ? jsonDecode(admin.body)['message'] ?? "Произошла ошибка."
                : "Пользователей не найдено.";

        if (!mounted) return;

        errorDialog(
          context: context,
          statusCode: admin.statusCode,
          description: error,
          color: Colors.green,
        );
      }

      final registerData = TaskModel(
        id: 1,
        title: _titleController.text,
        description: _descriptionController.text,
        createdAt: DateTime.now(),
        status: _selectedItem!,
        senderId: user.id,
        workerId: '',
      );

      var result = await http.post(
        Uri.parse(ApiEndpoints.addTask),
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
        title: "Новая задача",
        color: AppColors.userPage,
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
                  textField(
                    textController: _titleController,
                    labelText: "Заголовок",
                  ),
                  const SizedBox(height: 20),
                  textField(
                    textController: _descriptionController,
                    labelText: "Дополнительная информация",
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration:
                        BorderStyles
                            .roleDropdownButtonFormFieldInputDecoration1,
                    value: _selectedItem,
                    isExpanded: true,
                    items:
                        items
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedItem = newValue;
                      });
                    },
                    validator:
                        (value) =>
                            value == null
                                ? 'Пожалуйста, выберите сотояние'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  submitButton(
                    context: context,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    title: "Отправить",
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
