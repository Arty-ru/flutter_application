import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/accounts/login.dart';
import 'package:flutter_application/constants/api_endpoints.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/constants/token_handler.dart';
import 'package:flutter_application/models/user_model.dart';
import 'package:flutter_application/services/fetch_email.dart';
import 'package:flutter_application/services/role_check.dart';
import 'package:flutter_application/shared/custom_appbar.dart';
import 'package:flutter_application/shared/error_dialog.dart';
import 'package:flutter_application/shared/submit_button.dart';
import 'package:flutter_application/shared/user_details.dart';
import 'package:flutter_application/staff_area/add_staff_task.dart';
import 'package:flutter_application/staff_area/edit_staff_profile.dart';
import 'package:flutter_application/staff_area/get_tasks.dart';
import 'package:flutter_application/user_area/change_user_password.dart';
import 'package:flutter_application/user_area/edit_user_profile.dart';
import 'package:http/http.dart' as http;

class StaffMainPage extends StatefulWidget {
  const StaffMainPage({super.key});

  @override
  State<StaffMainPage> createState() => _UsersMainPageState();
}

class _UsersMainPageState extends State<StaffMainPage> {
  List<Map<String, dynamic>> buttons = [];
  late String email;

  @override
  void initState() {
    super.initState();
    RoleCheck().checkStaffRole(context);
    email = fetchEmailFromToken(context: context);
    addButtonData(context);
  }

  Future<void> getStaffInfo({required String email}) async {
    if (email.isEmpty) {
      return;
    }

    final result = await http.post(
      Uri.parse(ApiEndpoints.staffInfoRead),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await TokenHandler().getToken()}',
      },
      body: jsonEncode(email),
    );

    if (result.statusCode >= 200 && result.statusCode <= 299) {
      final jsonData = json.decode(result.body);
      final user = UserModel.fromJson(jsonData);

      if (!mounted) return;
      userDetails(context: context, user: user, color: AppColors.userPage);
    } else {
      var errorBody = jsonDecode(result.body);
      final error = errorBody['message'] ?? "Возникла ошибка.";

      if (!mounted) return;

      errorDialog(
        context: context,
        statusCode: result.statusCode,
        description: error,
        color: Colors.green,
      );
    }
  }

  Future<void> deleteUserAccount({required String email}) async {
    if (email.isEmpty) {
      return;
    }

    final result = await http.delete(
      Uri.parse(ApiEndpoints.userDeleteProfile),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${TokenHandler().getToken()}',
      },
      body: jsonEncode(email),
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
      final error = errorBody['message'] ?? "Возникла ошибка.";

      if (!mounted) return;

      errorDialog(
        context: context,
        statusCode: result.statusCode,
        description: error,
        color: Colors.green,
      );
    }
  }

  void addButtonData(BuildContext context) {
    buttons.addAll([
      {
        'title': 'Информация о пользователе',
        'backgroundColor': AppColors.userPage,
        'textColor': Colors.white,
        'onPressed': () {
          getStaffInfo(email: email);
        },
      },
      {
        'title': 'Редактировать профиль',
        'backgroundColor': AppColors.userPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditStaffProfile(email: email),
            ),
          );
        },
      },
      {
        'title': 'Просмотреть заявки',
        'backgroundColor': AppColors.userPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GetStaffTasks()),
          );
        },
      },
      {
        'title': 'Добавить заявку',
        'backgroundColor': AppColors.userPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddStaffTask(
                    email: fetchEmailFromToken(context: context),
                  ),
            ),
          );
        },
      },
      {
        'title': 'Сменить пароль',
        'backgroundColor': AppColors.userPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeUserPassword(email: email),
            ),
          );
        },
      },
      {
        'title': 'Выйти',
        'backgroundColor': AppColors.userPage,
        'textColor': Colors.white,
        'onPressed': () {
          TokenHandler().clearToken();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        },
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: "Страница пользователя",
        color: AppColors.userPage,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Опции пользователя"),
            const SizedBox(height: 20),
            ListView.builder(
              itemCount: buttons.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    submitButton(
                      context: context,
                      backgroundColor: buttons[index]['backgroundColor'],
                      textColor: buttons[index]['textColor'],
                      title: buttons[index]['title'],
                      method: buttons[index]['onPressed'],
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
