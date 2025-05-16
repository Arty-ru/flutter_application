import 'package:flutter/material.dart';
import 'package:flutter_application/accounts/login.dart';
import 'package:flutter_application/admin_area/add_role.dart';
import 'package:flutter_application/admin_area/add_task.dart';
import 'package:flutter_application/admin_area/add_user.dart';
import 'package:flutter_application/admin_area/change_admin_password.dart';
import 'package:flutter_application/admin_area/edit_profile.dart';
import 'package:flutter_application/admin_area/get_roles.dart';
import 'package:flutter_application/admin_area/get_tasks.dart';
import 'package:flutter_application/admin_area/get_users.dart';
import 'package:flutter_application/admin_area/select_user.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/constants/token_handler.dart';
import 'package:flutter_application/services/fetch_email.dart';
import 'package:flutter_application/services/role_check.dart';
import 'package:flutter_application/shared/custom_appbar.dart';
import 'package:flutter_application/shared/submit_button.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  List<Map<String, dynamic>> buttons = [];
  late String email;

  @override
  void initState() {
    RoleCheck().checkAdminRole(context);
    email = fetchEmailFromToken(context: context);
    addButtonData(context);
    super.initState();
  }

  void addButtonData(BuildContext context) {
    buttons.addAll([
      {
        'title': 'Пользователи',
        'backgroundColor': AppColors.adminPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GetUsers()),
          );
        },
      },
      {
        'title': 'Добавить пользователя',
        'backgroundColor': AppColors.adminPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddUser()),
          );
        },
      },
      {
        'title': 'Роли',
        'backgroundColor': AppColors.adminPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GetRoles()),
          );
        },
      },
      {
        'title': 'Доавить роль',
        'backgroundColor': AppColors.adminPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRole()),
          );
        },
      },
      {
        'title': 'Просмотреть заявки',
        'backgroundColor': AppColors.adminPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GetTasks()),
          );
        },
      },
      {
        'title': 'Добавить заявку',
        'backgroundColor': AppColors.adminPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      AddTask(email: fetchEmailFromToken(context: context)),
            ),
          );
        },
      },
      {
        'title': 'Изменить роль пользователя',
        'backgroundColor': AppColors.adminPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SelectUser()),
          );
        },
      },
      {
        'title': 'Изменить профиль',
        'backgroundColor': AppColors.adminPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfile(email: email)),
          );
        },
      },
      {
        'title': 'Сменить пароль',
        'backgroundColor': AppColors.adminPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeAdminPassword(email: email),
            ),
          );
        },
      },
      {
        'title': 'Выйти',
        'backgroundColor': AppColors.adminPage,
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
        title: "Секция администратора",
        color: AppColors.adminPage,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Инструменты администратора"),
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
