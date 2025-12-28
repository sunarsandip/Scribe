import 'dart:convert';

class TodoModel {
  final String todoId;
  final String meetingId;
  final String title;
  final bool isCompleted;
  final String priority;

  TodoModel({
    required this.todoId,
    required this.meetingId,
    required this.title,
    required this.isCompleted,
    required this.priority,
  });

  TodoModel copyWith({
    String? todoId,
    String? meetingId,
    String? title,
    bool? isCompleted,
    String? priority,
  }) {
    return TodoModel(
      todoId: todoId ?? this.todoId,
      meetingId: meetingId ?? this.meetingId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'todoId': todoId,
      'meetingId': meetingId,
      'title': title,
      'isCompleted': isCompleted,
      'priority': priority,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      todoId: map['todoId'] ?? '',
      meetingId: map['meetingId'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      priority: map['priority'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoModel.fromJson(String source) =>
      TodoModel.fromMap(json.decode(source));
}