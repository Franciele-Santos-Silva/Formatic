import 'package:flutter/material.dart';
import 'package:formatic/services/tasks/task_service.dart';
import 'package:formatic/services/auth/auth_service.dart';
import '../models/task_ui.dart';
import '../utils/task_mapper.dart';

class TaskController extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();

  final List<TaskUI> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskUI> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tasksFromDb = await _taskService.getTasks();
      _tasks.clear();
      _tasks.addAll(TaskMapper.fromTaskList(tasksFromDb));
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar tarefas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(TaskUI task) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        _error = 'Usuário não autenticado';
        notifyListeners();
        return;
      }

      final taskForDb = TaskMapper.toTask(task, userId);
      final createdTask = await _taskService.createTask(taskForDb);
      final taskUI = TaskMapper.fromTask(createdTask);

      _tasks.add(taskUI);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao criar tarefa: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTask(TaskUI task) async {
    if (task.id == null) return;

    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        _error = 'Usuário não autenticado';
        notifyListeners();
        return;
      }

      final taskForDb = TaskMapper.toTask(task, userId);
      final updatedTask = await _taskService.updateTask(taskForDb);
      final taskUI = TaskMapper.fromTask(updatedTask);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = taskUI;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao atualizar tarefa: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao deletar tarefa: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleTaskStatus(String taskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );

    await updateTask(updatedTask);
  }

  List<TaskUI> searchTasks(String query) {
    if (query.isEmpty) return _tasks;

    final lowerQuery = query.toLowerCase();
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
          (task.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<TaskUI> getTasksForMonth(int year, int month) {
    return _tasks.where((task) {
      return task.dueDate.year == year && task.dueDate.month == month;
    }).toList();
  }

  List<TaskUI> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      return task.dueDate.year == date.year &&
          task.dueDate.month == date.month &&
          task.dueDate.day == date.day;
    }).toList();
  }
}
