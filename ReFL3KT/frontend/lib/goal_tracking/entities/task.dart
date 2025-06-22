class Task {
  String id;
  String name;
  int? category;
  bool isRecurring;
  String status;
  double timeSpent; // in hours

  Task({
    required this.id,
    required this.name,
    required this.category,
    required this.isRecurring,
    this.status = 'not_started',
    this.timeSpent = 0.0,
  });

  // Getter for backward compatibility
  bool get isComplete => status == 'completed';

  Task copyWith({
    String? id,
    String? name,
    int? category,
    bool? isRecurring,
    String? status,
    double? timeSpent,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
      status: status ?? this.status,
      timeSpent: timeSpent ?? this.timeSpent,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      name: json['title'],
      category: json['category'],
      isRecurring: json['is_recurring'] ?? false,
      status: json['status'] ?? 'not_started',
      timeSpent:
          (json['actual_time_spent'] ?? 0) / 60.0, // Convert minutes to hours
    );
  }
}
