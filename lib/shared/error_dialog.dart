import 'package:flutter/material.dart';
import 'package:flutter_application/constants/border_styles.dart';

void errorDialog({
  required BuildContext context,
  required int statusCode,
  required String description,
  required Color color,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text("Ошибка"),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Код ошибки: $statusCode"),
            Text("Описание: $description"),
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
