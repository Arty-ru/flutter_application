//Для получения
class TaskViewModel {
  final int id;
  final String title;
  final String description;
  final String createdAt;
  final String status;
  final String? sender;
  final String? phone;
  final String? address;
  final String? worker;
  final String? workerPhone;

  const TaskViewModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
    this.sender,
    this.phone,
    this.address,
    this.worker,
    this.workerPhone,
  });

  factory TaskViewModel.fromJson(Map<String, dynamic> json) {
    return TaskViewModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: json['createdAt'] as String,
      status: json['status'] as String,
      sender: json['sender'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      worker: json['worker'] as String?,
      workerPhone: json['workerPhone'] as String?,
    );
  }
}
