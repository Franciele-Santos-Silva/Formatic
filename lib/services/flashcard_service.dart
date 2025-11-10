import '../models/flashcard.dart';
import 'supabase_config.dart';

class FlashcardService {
  final client = SupabaseConfig.client;

  Future<List<Flashcard>> getUserFlashcards(String id) async {
    final response = await client
        .from('flashcards')
        .select()
        .order('created_at', ascending: false);
  

    return (response as List).map((e) => Flashcard.fromJson(e)).toList();
  }

  Future<void> addFlashcard(Flashcard flashcard) async {
    await client.from('flashcards').insert(flashcard.toJson());
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    await client
        .from('flashcards')
        .update(flashcard.toJson())
        .eq('id', flashcard.id);
  }

  Future<void> deleteFlashcard(String flashcardId) async {
    await client
        .from('flashcards')
        .delete()
        .eq('id', flashcardId);
  } 
}





