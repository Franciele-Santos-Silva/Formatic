import 'package:formatic/models/flashcards/flashcard.dart';

import '../core/supabase_config.dart';
import '../core/activity_logger_service.dart';

class FlashcardService {
  final client = SupabaseConfig.client;

  Future<List<Flashcard>> getUserFlashcards(String userId) async {
    final response = await client
        .from('flashcards')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Flashcard.fromJson(e)).toList();
  }

  Future<void> createFlashcard({
    required String userId,
    required String question,
    required String answer,
  }) async {
    final response = await client
        .from('flashcards')
        .insert({'user_id': userId, 'question': question, 'answer': answer})
        .select()
        .single();

    await ActivityLoggerService.logActivity(
      action: ActivityLoggerService.actionAdd,
      type: ActivityLoggerService.typeFlashcard,
      itemId: response['id'].toString(),
      itemName: question,
    );
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    await client
        .from('flashcards')
        .update(flashcard.toJson())
        .eq('id', flashcard.id);

    await ActivityLoggerService.logActivity(
      action: ActivityLoggerService.actionEdit,
      type: ActivityLoggerService.typeFlashcard,
      itemId: flashcard.id.toString(),
      itemName: flashcard.question,
    );
  }

  Future<void> deleteFlashcard(String flashcardId) async {
    final flashcard = await client
        .from('flashcards')
        .select()
        .eq('id', flashcardId)
        .single();

    await client.from('flashcards').delete().eq('id', flashcardId);

    await ActivityLoggerService.logActivity(
      action: ActivityLoggerService.actionDelete,
      type: ActivityLoggerService.typeFlashcard,
      itemId: flashcardId,
      itemName: flashcard['question'],
    );
  }
}
