import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants/api_endpoints.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/constants/token_handler.dart';
import 'package:flutter_application/models/task_view_model.dart';
import 'package:flutter_application/services/role_check.dart';
import 'package:flutter_application/shared/custom_appbar.dart';
import 'package:flutter_application/shared/task_details.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/shared/error_dialog.dart';

class GetStaffTasks extends StatefulWidget {
  const GetStaffTasks({super.key});

  @override
  State<GetStaffTasks> createState() => _GetTasksState();
}

class _GetTasksState extends State<GetStaffTasks> {
  List<TaskViewModel> tasks = [];

  @override
  void initState() {
    super.initState();
    RoleCheck().checkStaffRole(context);
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final result = await http.get(
      Uri.parse(ApiEndpoints.getAllTasks),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${TokenHandler().getToken()}',
      },
    );

    if (result.statusCode >= 200 && result.statusCode <= 299) {
      final List<dynamic> jsonData = json.decode(result.body);
      setState(() {
        tasks = jsonData.map((task) => TaskViewModel.fromJson(task)).toList();
      });
    } else {
      var errorBody;
      var error;
      if (result.body.isNotEmpty) {
        errorBody = jsonDecode(result.body);
        error = errorBody['message'] ?? "Произошла ошибка. ";
      } else {
        error = "Заявок не найдено.";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: "Заявки", color: AppColors.userPage),
      body: ListView.builder(
        itemCount: tasks.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          final task = tasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            leading: CircleAvatar(child: Text(task.id.toString())),
            onTap: () {
              taskDetails(
                context: context,
                task: task,
                color: AppColors.userPage,
              );
            },
          );
        },
      ),
    );
  }
}
