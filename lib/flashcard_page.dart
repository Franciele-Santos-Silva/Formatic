import 'package:flutter/material.dart';
import 'package:formatic/services/auth_service.dart';
import 'package:formatic/services/flashcard_service.dart';
import 'package:formatic/models/flashcard.dart';
import 'widgets/app_top_nav_bar.dart';

class FlashcardPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const FlashcardPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final FlashcardService _flashcardService = FlashcardService();
  List<Flashcard> _flashcards = [];
  bool _loading = true;
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    setState(() => _loading = true);

    try {
      final user = AuthService().currentUser;
      if (user != null) {
        final flashcards = await _flashcardService.getUserFlashcards(user.id);
        setState(() => _flashcards = flashcards);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar flashcards: $e')),
        );
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _addFlashcard() async {
    if (_questionController.text.isEmpty || _answerController.text.isEmpty) {
      return;
    }

    try {
      final user = AuthService().currentUser;
      if (user == null) return;

      final flashcard = Flashcard(
        id: 0, // O ID será gerado pelo backend
        userId: user.id,
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _flashcardService.addFlashcard(flashcard);

      _questionController.clear();
      _answerController.clear();

      await _loadFlashcards();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Flashcard adicionado!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar flashcard: $e')),
        );
      }
    }
  }

  void _showAddFlashcardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Pergunta',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Resposta',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _questionController.clear();
              _answerController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addFlashcard();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopNavBar(
        title: 'Flashcards',
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _flashcards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum flashcard encontrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no botão + para adicionar',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _flashcards.length,
              itemBuilder: (context, index) {
                final flashcard = _flashcards[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(
                      flashcard.question,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Criado em: ${flashcard.createdAt.day}/${flashcard.createdAt.month}/${flashcard.createdAt.year}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            flashcard.answer,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFlashcardDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }
}
