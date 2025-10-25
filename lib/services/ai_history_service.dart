// import '../models/ai_history.dart';
// import 'supabase_config.dart';

// class AiHistoryService {
//   final client = SupabaseConfig.client;

//   Future<List<AiHistory>> getUserHistory(String userId) async {
//     final response = await client
//         .from('ai_history')
//         .select()
//         .eq('user_id', userId)
//         .order('created_at', ascending: false);
//     return (response as List).map((e) => AiHistory.fromJson(e)).toList();
//   }

//   Future<void> addHistory(AiHistory history) async {
//     await client.from('ai_history').insert(history.toJson());
//   }
// }

import '../models/ai_history.dart';
import 'supabase_config.dart';

class AiHistoryService {
  final client = SupabaseConfig.client;

  Future<List<AiHistory>> getUserHistory(String userId) async {
    try {
      final response = await client
          .from('ai_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((e) => AiHistory.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao buscar histórico: $e');
      return [];
    }
  }

  Future<void> addHistory(String userId, String question, String answer) async {
    try {
      await client.from('ai_history').insert({
        'user_id': userId,
        'question': question,
        'answer': answer,
      });
    } catch (e) {
      print('Erro ao adicionar histórico: $e');
      rethrow;
    }
  }
}