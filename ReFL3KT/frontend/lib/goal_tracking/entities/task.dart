// Task Model
class Task {
  String id;
  String name;
  String category;
  bool isRecurring;
  bool isComplete;
  double timeSpent; // in hours

  Task({
    required this.id,
    required this.name,
    required this.category,
    required this.isRecurring,
    this.isComplete = false,
    this.timeSpent = 0.0,
  });

  Task copyWith({
    String? id,
    String? name,
    String? category,
    bool? isRecurring,
    bool? isComplete,
    double? timeSpent,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
      isComplete: isComplete ?? this.isComplete,
      timeSpent: timeSpent ?? this.timeSpent,
    );
  }
}
