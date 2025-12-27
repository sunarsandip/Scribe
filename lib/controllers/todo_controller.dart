import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:scribe/models/todo_model.dart';

class TodoController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // toggle todo isComplete field;
  Future<void> toggleTodoIsComplete(
    String meetingId,
    String todoId,
    bool isCompleted, {
    Function(List<Map<String, dynamic>>)? onOptimisticUpdate,
  }) async {
    try {
      final docRef = firestore.collection("meetings").doc(meetingId);
      final doc = await docRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final todoData = data['toDo'] as List<dynamic>? ?? [];
      final todos = todoData.map((e) => Map<String, dynamic>.from(e)).toList();

      final idx = todos.indexWhere((t) => t['todoId'] == todoId);
      if (idx == -1) return;

      // Update the specific todo while maintaining order
      todos[idx] = Map<String, dynamic>.from(todos[idx])
        ..['isCompleted'] = isCompleted;

      // Call the callback to update UI immediately
      if (onOptimisticUpdate != null) {
        onOptimisticUpdate(todos);
      }

      // Update Firestore with the entire array to maintain order
      await docRef.update({'toDo': todos});
    } catch (e) {
      debugPrint("Failed to toggle complete: $e");
    }
  }

  // method to update todo
  Future<void> updateTodo(TodoModel newTodo, String meetingId) async {
    try {
      final docRef = firestore.collection("meetings").doc(meetingId);
      final doc = await docRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final todoData = data['toDo'] as List<dynamic>? ?? [];
      final todos = todoData.map((e) => Map<String, dynamic>.from(e)).toList();

      final idx = todos.indexWhere((t) => t["todoId"] == newTodo.todoId);
      if (idx == -1) return;

      todos[idx] = newTodo.toMap();

      await docRef.update({"toDo": todos});

    } catch (e) {
      debugPrint("Failed to update todo: $e");
    }
  }

  // delete todo
  Future<void> deleteTodo(int todoIndex, String meetingId) async {
    final docRef = firestore.collection("meetings").doc(meetingId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final rawTodo = data['toDo'] as List<dynamic>? ?? [];
    final todos = rawTodo.map((e) => Map<String, dynamic>.from(e)).toList();
    if (todoIndex < 0 || todoIndex >= todos.length) return;

    todos.removeAt(todoIndex);
    await docRef.update({'toDo': todos});
  }
}