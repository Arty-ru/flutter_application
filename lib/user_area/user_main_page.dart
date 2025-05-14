import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/accounts/login.dart';
import 'package:flutter_application/constants/api_endpoints.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/constants/token_handler.dart';
import 'package:flutter_application/models/user_model.dart';
import 'package:flutter_application/services/fetch_email.dart';
import 'package:flutter_application/services/role_check.dart';
import 'package:flutter_application/shared/confirmation_dialog.dart';
import 'package:flutter_application/shared/custom_appbar.dart';
import 'package:flutter_application/shared/error_dialog.dart';
import 'package:flutter_application/shared/submit_button.dart';
import 'package:flutter_application/shared/user_details.dart';
import 'package:flutter_application/user_area/change_user_password.dart';
import 'package:flutter_application/user_area/edit_user_profile.dart';
import 'package:http/http.dart' as http;

class UsersMainPage extends StatefulWidget {
  const UsersMainPage({super.key});

  @override
  State<UsersMainPage> createState() => _UsersMainPageState();
}

class _UsersMainPageState extends State<UsersMainPage> {
  List<Map<String, dynamic>> buttons = [];
  late String email;

  @override
  void initState() {
    super.initState();
    RoleCheck().checkUserRole(context);
    email = fetchEmailFromToken(context: context);
    addButtonData(context);
  }

  Future<void> getUserInfo({required String email}) async {
    if (email.isEmpty) {
      return;
    }

    final result = await http.post(
      Uri.parse(ApiEndpoints.userInfoReadUpdate),
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
          getUserInfo(email: email);
        },
      },
      {
        'title': 'Edit Profile',
        'backgroundColor': AppColors.userPage,
        'textColor': Colors.white,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditUserProfile(email: email),
            ),
          );
        },
      },
      {
        'title': 'Change Password',
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
        'title': 'Delete Account',
        'backgroundColor': AppColors.userPage,
        'textColor': Colors.white,
        'onPressed': () async {
          bool? confirmed = await showConfirmationDialog(
            context: context,
            title: "Confirm",
            content: "Вы уверены, что хотите удалить этот профиль?",
            color: AppColors.userPage,
          );

          if (confirmed) {
            deleteUserAccount(email: email);
          } else {
            return;
          }
        },
      },
      {
        'title': 'Logout',
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
