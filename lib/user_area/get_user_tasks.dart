import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants/api_endpoints.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/constants/token_handler.dart';
import 'package:flutter_application/models/task_view_model.dart';
import 'package:flutter_application/services/role_check.dart';
import 'package:flutter_application/shared/confirmation_dialog.dart';
import 'package:flutter_application/shared/custom_appbar.dart';
import 'package:flutter_application/shared/task_details.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/shared/error_dialog.dart';

class GetUserTasks extends StatefulWidget {
  final String email;
  const GetUserTasks({super.key, required this.email});

  @override
  State<GetUserTasks> createState() => _GetTasksState();
}

class _GetTasksState extends State<GetUserTasks> {
  List<TaskViewModel> tasks = [];

  @override
  void initState() {
    super.initState();
    RoleCheck().checkUserRole(context);
    fetchTasks(widget.email);
  }

  Future<void> fetchTasks(String email) async {
    final uri = Uri.parse('${ApiEndpoints.getUserTasks}?email=$email');

    final result = await http.get(
      uri,
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

  Future<void> deleteTask({required int? id}) async {
    final result = await http.delete(
      Uri.parse(ApiEndpoints.deleteTask),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${TokenHandler().getToken()}',
      },
      body: jsonEncode(id),
    );

    if (result.statusCode >= 200 && result.statusCode <= 299) {
      fetchTasks(widget.email);
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
            trailing: IconButton(
              onPressed: () async {
                bool? confirmed = await showConfirmationDialog(
                  context: context,
                  title: "Принять",
                  content: "Вы уверены, что хотите удалить эту заявку?",
                  color: AppColors.userPage,
                );

                if (confirmed) {
                  deleteTask(id: task.id);
                } else {
                  return;
                }
              },
              icon: const Icon(Icons.delete),
            ),
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
