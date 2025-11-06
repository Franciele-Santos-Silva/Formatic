import '../models/study_session.dart';
import '../models/study_metrics.dart';
import 'supabase_config.dart';

class StudyService {
  final client = SupabaseConfig.client;

  Future<List<StudySession>> getUserSessions() async {
    final response = await client
        .from('study_sessions')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => StudySession.fromJson(e)).toList();
  }

  Future<StudySession> startSession(StudySession session) async {
    final response = await client
        .from('study_sessions')
        .insert(session.toJson())
        .select()
        .single();

    return StudySession.fromJson(response);
  }

  Future<StudySession> completeSession(String sessionId) async {
    final response = await client
        .from('study_sessions')
        .update({'completed': true})
        .eq('id', sessionId)
        .select()
        .single();

    return StudySession.fromJson(response);
  }

  Future<void> deleteSession(String sessionId) async {
    await client
        .from('study_sessions')
        .delete()
        .eq('id', sessionId);
  }

  Future<StudyMetrics?> getTodayMetrics() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final response = await client
        .from('study_metrics')
        .select()
        .eq('date', today)
        .maybeSingle();

    return response != null ? StudyMetrics.fromJson(response) : null;
  }

  Future<StudyMetrics> updateMetrics(StudyMetrics metrics) async {
    final response = await client
        .from('study_metrics')
        .upsert(metrics.toJson())
        .select()
        .single();

    return StudyMetrics.fromJson(response);
  }

  Future<List<StudyMetrics>> getWeeklyMetrics() async {
    final weekAgo = DateTime.now().subtract(Duration(days: 7));
    final formattedDate = weekAgo.toIso8601String().split('T')[0];

    final response = await client
        .from('study_metrics')
        .select()
        .gte('date', formattedDate)
        .order('date', ascending: true);

    return (response as List).map((e) => StudyMetrics.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getTodayStats() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final response = await client
        .from('study_sessions')
        .select('duration_minutes, session_type')
        .eq('completed', true)
        .gte('created_at', today);

    int totalMinutes = 0;
    int pomodoroCount = 0;

    for (var session in response) {
      totalMinutes += session['duration_minutes'] as int;
      if (session['session_type'].toString().contains('pomodoro')) {
        pomodoroCount++;
      }
    }

    return {
      'totalMinutes': totalMinutes,
      'pomodoroSessions': pomodoroCount,
      'sessionCount': response.length,
    };
  }
}