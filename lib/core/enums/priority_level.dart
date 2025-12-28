import 'package:flutter/material.dart';

enum PriorityLevel {
  low,
  medium,
  high,
  urgent;

  String get text {
    switch (this) {
      case PriorityLevel.low:
        return 'Low';
      case PriorityLevel.medium:
        return 'Medium';
      case PriorityLevel.high:
        return 'High';
      case PriorityLevel.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case PriorityLevel.low:
        return Colors.green;
      case PriorityLevel.medium:
        return Colors.orange;
      case PriorityLevel.high:
        return Colors.red;
      case PriorityLevel.urgent:
        return Colors.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case PriorityLevel.low:
        return Icons.keyboard_arrow_down;
      case PriorityLevel.medium:
        return Icons.drag_handle;
      case PriorityLevel.high:
        return Icons.keyboard_arrow_up;
      case PriorityLevel.urgent:
        return Icons.keyboard_double_arrow_up;
    }
  }

  static PriorityLevel fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return PriorityLevel.low;
      case 'medium':
        return PriorityLevel.medium;
      case 'high':
        return PriorityLevel.high;
      case 'urgent':
        return PriorityLevel.urgent;
      default:
        return PriorityLevel.low;
    }
  }
}