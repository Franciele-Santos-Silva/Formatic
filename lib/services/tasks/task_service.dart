import 'package:formatic/models/tasks/task.dart';

import '../core/supabase_config.dart';
import '../core/activity_logger_service.dart';

class TaskService {
  final client = SupabaseConfig.client;

  Future<Task> createTask(Task task) async {
    final response = await client
        .from('tasks')
        .insert(task.toJson())
        .select()
        .single();

    final createdTask = Task.fromJson(response);

    await ActivityLoggerService.logActivity(
      action: ActivityLoggerService.actionAdd,
      type: ActivityLoggerService.typeTask,
      itemId: createdTask.id,
      itemName: createdTask.title,
    );

    return createdTask;
  }

  Future<List<Task>> getTasks() async {
    final response = await client
        .from('tasks')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => Task.fromJson(e)).toList();
  }

  Future<Task> updateTask(Task task) async {
    final response = await client
        .from('tasks')
        .update(task.toJson())
        .eq('id', task.id)
        .select()
        .single();

    final updatedTask = Task.fromJson(response);

    await ActivityLoggerService.logActivity(
      action: ActivityLoggerService.actionEdit,
      type: ActivityLoggerService.typeTask,
      itemId: updatedTask.id,
      itemName: updatedTask.title,
    );

    return updatedTask;
  }

  Future<void> deleteTask(String taskId) async {
    final task = await client.from('tasks').select().eq('id', taskId).single();

    await client.from('tasks').delete().eq('id', taskId);

    await ActivityLoggerService.logActivity(
      action: ActivityLoggerService.actionDelete,
      type: ActivityLoggerService.typeTask,
      itemId: taskId,
      itemName: task['title'],
    );
  }
}
