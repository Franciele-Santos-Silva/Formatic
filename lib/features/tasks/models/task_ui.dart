import 'package:flutter/material.dart';

/// Modelo de Task para representação na UI
/// Extende o modelo básico do banco com campos adicionais para a interface
class TaskUI {
  final String? id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final Color color;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskUI({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.dueTime,
    required this.color,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  TaskUI copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    Color? color,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskUI(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converte TimeOfDay para minutos desde meia-noite
  int get dueTimeInMinutes => dueTime.hour * 60 + dueTime.minute;

  /// Combina date e time em um DateTime completo
  DateTime get fullDueDateTime {
    return DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueTime.hour,
      dueTime.minute,
    );
  }

  /// Verifica se a tarefa está atrasada
  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    return fullDueDateTime.isBefore(now);
  }

  /// Verifica se a tarefa é para hoje
  bool get isToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }
}
