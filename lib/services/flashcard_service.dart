// import '../models/flashcard.dart';
// import 'supabase_config.dart';

// class FlashcardService {
//   final client = SupabaseConfig.client;

//   Future<List<Flashcard>> getUserFlashcards(String userId) async {
//     final response = await client
//         .from('flashcards')
//         .select()
//         .eq('user_id', userId)
//         .order('created_at', ascending: false);

//     return (response as List).map((e) => Flashcard.fromJson(e)).toList();
//   }

//   Future<void> addFlashcard(Flashcard flashcard) async {
//     await client.from('flashcards').insert(flashcard.toJson());
//   }
// }

import '../models/flashcard.dart';
import 'supabase_config.dart';

class FlashcardService {
  final client = SupabaseConfig.client;

  Future<List<Flashcard>> getUserFlashcards(String userId) async {
    try {
      final response = await client
          .from('flashcards')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => Flashcard.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao buscar flashcards: $e');
      return [];
    }
  }

  Future<void> addFlashcard(String userId, String question, String answer) async {
    try {
      await client.from('flashcards').insert({
        'user_id': userId,
        'question': question,
        'answer': answer,
      });
    } catch (e) {
      print('Erro ao adicionar flashcard: $e');
      rethrow;
    }
  }
}
