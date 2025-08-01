import 'package:flutter/material.dart';
import 'package:flutter_application/constants/app_colors.dart';
import 'package:flutter_application/shared/custom_appbar.dart';

class UnknownRoles extends StatefulWidget {
  const UnknownRoles({super.key});

  @override
  State<UnknownRoles> createState() => _UnknownRolesState();
}

class _UnknownRolesState extends State<UnknownRoles> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppbar(
        title: "Unknown Role",
        color: AppColors.unknownRolesPage,
      ),
      body: Center(
        child: Text("Unknown user Role\nContact admin to solve this issue."),
      ),
    );
  }
}
