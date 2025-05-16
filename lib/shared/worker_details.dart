import 'package:flutter/material.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/constants/border_styles.dart';
import 'package:flutter_application/shared/text_fields.dart';

void workerDetails({
  required BuildContext context,
  required String? workerName,
  required String? workerPhone,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text("Информация о работнике"),
            const SizedBox(height: 10),
            userDetailsTextField(
              label: "Имя",
              value: workerName ?? 'Неизвестно',
            ),
            const SizedBox(height: 10),
            userDetailsTextField(
              label: "Телефон",
              value: workerPhone ?? "Не указан",
            ),
          ],
        ),
        actions: [
          MaterialButton(
            color: AppColors.userPage,
            textColor: Colors.white,
            padding: const EdgeInsets.all(18),
            hoverElevation: 0,
            elevation: 0,
            focusElevation: 0,
            shape: BorderStyles.buttonBorder,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Ok"),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      );
    },
  );
}
