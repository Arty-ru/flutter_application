import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/constants/border_styles.dart';

TextFormField userNameTextField({
  bool readOnly = false,
  required TextEditingController nameController,
}) {
  return TextFormField(
    controller: nameController,
    decoration: InputDecoration(
      labelText: 'Имя пользователя',
      floatingLabelStyle: const TextStyle(color: Colors.green),
      border: BorderStyles.border,
      focusedBorder: BorderStyles.focusedBorder,
      errorBorder: BorderStyles.errorBorder,
      focusedErrorBorder: BorderStyles.focusedErrorBorder,
    ),
    keyboardType: TextInputType.name,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Пожалуйста, введите Ваше имя.';
      }
      return null;
    },
  );
}

TextFormField emailTextField({
  required TextEditingController emailController,
  bool readOnly = false,
}) {
  return TextFormField(
    controller: emailController,
    decoration: InputDecoration(
      labelText: "Email",
      floatingLabelStyle: const TextStyle(color: Colors.green),
      border: BorderStyles.border,
      focusedBorder: BorderStyles.focusedBorder,
      errorBorder: BorderStyles.errorBorder,
      focusedErrorBorder: BorderStyles.focusedErrorBorder,
    ),
    keyboardType: TextInputType.emailAddress,
    readOnly: readOnly,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Пожалуйста, введите Вашу почту.';
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
        return 'Почта введена некорректно.';
      }
      return null;
    },
  );
}

TextFormField passwordTextField({
  required TextEditingController passwordController,
  String? label,
}) {
  return TextFormField(
    controller: passwordController,
    decoration: InputDecoration(
      labelText: label ?? "Пароль",
      floatingLabelStyle: const TextStyle(color: Colors.green),
      border: BorderStyles.border,
      focusedBorder: BorderStyles.focusedBorder,
      errorBorder: BorderStyles.errorBorder,
      focusedErrorBorder: BorderStyles.focusedErrorBorder,
    ),
    obscureText: true,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Пожалуйста, введите пароль.';
      }
      if (value.length < 6) {
        return "Ваш пароль должен содержать более 6 символов.";
      }
      return null;
    },
  );
}

TextFormField phoneNumberField({
  required TextEditingController phoneNumberController,
}) {
  return TextFormField(
    controller: phoneNumberController,
    decoration: InputDecoration(
      labelText: "Телефон",
      floatingLabelStyle: const TextStyle(color: Colors.green),
      border: BorderStyles.border,
      focusedBorder: BorderStyles.focusedBorder,
      errorBorder: BorderStyles.errorBorder,
      focusedErrorBorder: BorderStyles.focusedErrorBorder,
    ),
    keyboardType: TextInputType.phone,
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
    ],
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Пожалуйста, введите номер Вашего телефона.';
      }
      if (value.length < 11) {
        return "Некорректный номер.";
      }
      return null;
    },
  );
}

TextField userDetailsTextField({required String label, required String value}) {
  return TextField(
    controller: TextEditingController(text: value),
    readOnly: true,
    decoration: InputDecoration(
      labelText: label,
      floatingLabelStyle: const TextStyle(color: Colors.green),
      border: BorderStyles.border,
      focusedBorder: BorderStyles.focusedBorder,
      errorBorder: BorderStyles.errorBorder,
      focusedErrorBorder: BorderStyles.focusedErrorBorder,
    ),
  );
}
