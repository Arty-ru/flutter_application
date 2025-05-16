//Для отправки
class TaskModel {
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String status;
  final String? senderId;
  final String? workerId;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
    this.senderId,
    this.workerId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] as String,
      senderId: json['senderId'] as String?,
      workerId: json['workerId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'senderId': senderId,
      'workerId': workerId,
    };
  }
}
