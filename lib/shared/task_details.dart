import 'package:flutter/material.dart';
import 'package:flutter_application/constants/border_styles.dart';
import 'package:flutter_application/models/task_view_model.dart';
import 'package:flutter_application/services/fetch_email.dart';
import 'package:flutter_application/shared/change_task.dart';
import 'package:flutter_application/shared/text_fields.dart';

void taskDetails({
  required BuildContext context,
  required TaskViewModel task,
  required Color color,
}) {
  String? selectedStatus = task.status;
  final List<String> statusOptions = ['New', 'In Progress', 'Completed'];
  var email = fetchEmailFromToken(context: context);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                userDetailsTextField(
                  label: "Отправитель",
                  value: task.sender ?? 'Неизвестный',
                ),
                const SizedBox(height: 10),
                userDetailsTextField(
                  label: "Телефон отправителя",
                  value: task.phone ?? '12345678910',
                ),
                const SizedBox(height: 10),
                const Text("Информация о заявке"),
                const SizedBox(height: 10),
                userDetailsTextField(label: "Id", value: task.id.toString()),
                const SizedBox(height: 10),
                userDetailsTextField(label: "Заголовок", value: task.title),
                const SizedBox(height: 10),
                userDetailsTextField(label: "Детали", value: task.description),
                const SizedBox(height: 10),
                userDetailsTextField(
                  label: "Дата создания",
                  value: task.createdAt.toString(),
                ),
                const SizedBox(height: 10),
                userDetailsTextField(label: "Статус", value: task.status),
                const SizedBox(height: 10),
                userDetailsTextField(
                  label: "Адрес",
                  value: task.address ?? 'Не указан',
                ),
                const SizedBox(height: 10),
                const Text("Информация о работнике"),
                const SizedBox(height: 10),
                userDetailsTextField(
                  label: "Имя",
                  value: task.worker ?? 'Неизвестно',
                ),
                const SizedBox(height: 10),
                userDetailsTextField(
                  label: "Телефон",
                  value: task.workerPhone ?? "Не указан",
                ),
              ],
            ),
            actions: [
              MaterialButton(
                color: color,
                textColor: Colors.white,
                padding: const EdgeInsets.all(18),
                hoverElevation: 0,
                elevation: 0,
                focusElevation: 0,
                shape: BorderStyles.buttonBorder,
                onPressed: () {
                  // Можно сохранить выбранный статус, если надо
                  //print('Selected status: $selectedStatus');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChangeTask(
                            email: email,
                            id: task.id,
                            color: color,
                          ),
                    ),
                  );
                },
                child: const Text("Изменить"),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        },
      );
    },
  );
}
