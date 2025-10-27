import '../models/flashcard.dart';
import 'supabase_config.dart';

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

  Future<void> addFlashcard(Flashcard flashcard) async {
    await client.from('flashcards').insert(flashcard.toJson());
  }
}
