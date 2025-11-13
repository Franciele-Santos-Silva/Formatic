import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:formatic/models/tasks/task.dart';
import '../models/task_ui.dart';

/// Mapper para converter entre Task (modelo do banco) e TaskUI (modelo da UI)
class TaskMapper {
  /// Converte Task do banco para TaskUI usado na interface
  static TaskUI fromTask(Task task) {
    Map<String, dynamic> metadata = {};
    String? actualDescription;

    if (task.description != null && task.description!.startsWith('##META##')) {
      try {
        final parts = task.description!.split('##META##');
        if (parts.length > 1) {
          metadata = jsonDecode(parts[1]);
          if (parts.length > 2) {
            actualDescription = parts[2];
          }
        }
      } catch (e) {
        actualDescription = task.description;
      }
    } else {
      actualDescription = task.description;
    }

    final dueDateTimeStr = metadata['dueDateTime'] as String?;
    DateTime dueDate;
    TimeOfDay dueTime;

    if (dueDateTimeStr != null) {
      final dueDateTime = DateTime.parse(dueDateTimeStr);
      dueDate = DateTime(dueDateTime.year, dueDateTime.month, dueDateTime.day);
      dueTime = TimeOfDay(hour: dueDateTime.hour, minute: dueDateTime.minute);
    } else {
      dueDate = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );
      dueTime = const TimeOfDay(hour: 12, minute: 0);
    }

    final colorValue = metadata['color'] as int?;
    final color = colorValue != null
        ? Color(colorValue)
        : const Color(0xFF8B2CF5);

    final isCompleted = metadata['isCompleted'] as bool? ?? false;

    return TaskUI(
      id: task.id,
      title: task.title,
      description: actualDescription,
      dueDate: dueDate,
      dueTime: dueTime,
      color: color,
      isCompleted: isCompleted,
      createdAt: task.createdAt,
    );
  }

  /// Converte TaskUI para Task do banco, incluindo userId
  static Task toTask(TaskUI taskUI, String userId) {
    final metadata = {
      'dueDateTime': taskUI.fullDueDateTime.toIso8601String(),
      'color': taskUI.color.value,
      'isCompleted': taskUI.isCompleted,
    };

    final metaString = '##META##${jsonEncode(metadata)}##META##';
    final fullDescription = taskUI.description != null
        ? '$metaString${taskUI.description}'
        : metaString;

    return Task(
      id: taskUI.id ?? '',
      userId: userId,
      title: taskUI.title,
      description: fullDescription,
      createdAt: taskUI.createdAt ?? DateTime.now(),
    );
  }

  /// Converte lista de Tasks para lista de TaskUI
  static List<TaskUI> fromTaskList(List<Task> tasks) {
    return tasks.map((task) => fromTask(task)).toList();
  }
}
