import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityLoggerService {
  static const String _activityKey = 'recent_activities';
  static const int _maxActivities = 5;

  static const String actionAdd = 'add';
  static const String actionEdit = 'edit';
  static const String actionDelete = 'delete';

  static const String typeTask = 'tarefa';
  static const String typeFlashcard = 'flashcard';
  static const String typeBook = 'book';

  static Future<void> logActivity({
    required String action,
    required String type,
    required String itemId,
    required String itemName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final activities = await getActivities();

    final newActivity = {
      'action': action,
      'type': type,
      'itemId': itemId,
      'itemName': itemName,
      'timestamp': DateTime.now().toIso8601String(),
    };

    activities.insert(0, newActivity);

    if (activities.length > _maxActivities) {
      activities.removeRange(_maxActivities, activities.length);
    }

    final jsonString = jsonEncode(activities);
    await prefs.setString(_activityKey, jsonString);
  }

  static Future<List<Map<String, dynamic>>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_activityKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentActivities({
    int hoursLimit = 24,
  }) async {
    final activities = await getActivities();
    final now = DateTime.now();

    return activities.where((activity) {
      final timestamp = DateTime.parse(activity['timestamp']);
      return now.difference(timestamp).inHours < hoursLimit;
    }).toList();
  }

  static Future<Map<String, dynamic>?> getLastActivity() async {
    final activities = await getRecentActivities(hoursLimit: 24);
    return activities.isNotEmpty ? activities.first : null;
  }

  static Future<void> clearActivities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activityKey);
  }

  static Future<void> cleanOldActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activities = await getActivities();
    final now = DateTime.now();

    final filteredActivities = activities.where((activity) {
      final timestamp = DateTime.parse(activity['timestamp']);
      return now.difference(timestamp).inDays < 7;
    }).toList();

    final jsonString = jsonEncode(filteredActivities);
    await prefs.setString(_activityKey, jsonString);
  }

  static String getActionText(String action, String type) {
    switch (action) {
      case actionAdd:
        if (type == typeFlashcard) return 'Criou flashcard';
        if (type == typeBook) return 'Adicionou livro';
        return 'Adicionou $type';
      case actionEdit:
        return 'Editou $type';
      case actionDelete:
        return 'Removeu $type';
      default:
        return 'Ação desconhecida';
    }
  }
}
