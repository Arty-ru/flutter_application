class ApiEndpoints {
  static const String apiUri = "https://localhost:7253";

  static const String login = "$apiUri/api/Account/login";

  static const String register = "$apiUri/api/Account/register";

  static const String adminUsersCrud = "$apiUri/api/Admin/users";

  static const String adminRolesCrud = "$apiUri/api/Admin/roles";

  static const String adminChangeUserRole =
      "$apiUri/api/Admin/change-user-role";

  static const String adminInfoGetAndUpdate = "$apiUri/api/Admin/admin-info";

  static const String adminChangePassword =
      "$apiUri/api/Admin/change-admin-password";

  static const String userInfoRead = "$apiUri/api/User/user-info";

  static const String userInfoUpdate = "$apiUri/api/User/user-update";

  static const String userDeleteProfile = "$apiUri/api/User/delete-user";

  static const String userChangePassword = "$apiUri/api/User/change-password";

  static const String staffInfoRead = "$apiUri/api/Staff/staff-info";

  static const String staffInfoUpdate = "$apiUri/api/Staff/staff-update";

  static const String staffChangePassword = "$apiUri/api/Staff/change-password";

  static const String getAllTasks = "$apiUri/api/Task/all-tasks";

  static const String getTaskInfo = "$apiUri/api/Task/task-info";

  static const String getUserTasks = "$apiUri/api/Task/user-tasks";

  static const String addTask = "$apiUri/api/Task/add-task";

  static const String updateTask = "$apiUri/api/Task/update-task";

  static const String deleteTask = "$apiUri/api/Task/delete-task";
}
