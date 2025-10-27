import '../models/flashcard.dart';
import 'supabase_config.dart';

class FlashcardService {
  final client = SupabaseConfig.client;

  // Buscar flashcards do usuário
  Future<List<Flashcard>> getUserFlashcards(String id) async {
    final response = await client
        .from('flashcards')
        .select()
        .order('created_at', ascending: false);
  

    return (response as List).map((e) => Flashcard.fromJson(e)).toList();
  }

  //  Adicionar flashcard
  Future<void> addFlashcard(Flashcard flashcard) async {
    await client.from('flashcards').insert(flashcard.toJson());
  }

  // - Atualizar flashcard
  Future<void> updateFlashcard(Flashcard flashcard) async {
    await client
        .from('flashcards')
        .update(flashcard.toJson())
        .eq('id', flashcard.id);
  }

//ADICIONAR - Deletar flashcard
  Future<void> deleteFlashcard(String flashcardId) async {
    await client
        .from('flashcards')
        .delete()
        .eq('id', flashcardId);
  }
}