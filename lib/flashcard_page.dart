// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:formatic/services/auth_service.dart';
import 'package:formatic/services/flashcard_service.dart';
import 'package:formatic/models/flashcard.dart';
import 'package:formatic/login_page.dart';

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

class _FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  final FlashcardService _flashcardService = FlashcardService();
  List<Flashcard> _flashcards = [];
  bool _loading = true;
  bool _isStudyMode = false;
  int _currentCardIndex = 0;
  bool _showAnswer = false;

  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadFlashcards() async {
    setState(() => _loading = true);

    try {
      final user = AuthService().currentUser;
      if (user != null) {
        final flashcards = await _flashcardService.getUserFlashcards(user.id);
        setState(() {
          _flashcards = flashcards;
          if (_flashcards.isNotEmpty &&
              _currentCardIndex >= _flashcards.length) {
            _currentCardIndex = 0;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao carregar flashcards: $e', isError: true);
      }
    }

    setState(() => _loading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _addFlashcard() async {
    if (_questionController.text.trim().isEmpty ||
        _answerController.text.trim().isEmpty) {
      _showSnackBar('Preencha todos os campos!', isError: true);
      return;
    }

    try {
      final user = AuthService().currentUser;
      if (user == null) {
        _showSnackBar('Usuário não autenticado!', isError: true);
        return;
      }

      // Não enviar id e created_at - serão gerados pelo Supabase
      final flashcardData = {
        'user_id': user.id,
        'question': _questionController.text.trim(),
        'answer': _answerController.text.trim(),
      };

      await _flashcardService.client.from('flashcards').insert(flashcardData);

      _questionController.clear();
      _answerController.clear();

      await _loadFlashcards();

      if (mounted) {
        _showSnackBar('Flashcard adicionado com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao adicionar flashcard: $e', isError: true);
      }
    }
  }

  Future<void> _deleteFlashcard(Flashcard flashcard) async {
    try {
      await _flashcardService.deleteFlashcard(flashcard.id.toString());
      await _loadFlashcards();
      if (mounted) {
        _showSnackBar('Flashcard deletado com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao deletar flashcard: $e', isError: true);
      }
    }
  }

  Future<void> _updateFlashcard(Flashcard flashcard) async {
    try {
      await _flashcardService.updateFlashcard(flashcard);
      await _loadFlashcards();
      if (mounted) {
        _showSnackBar('Flashcard atualizado com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao atualizar flashcard: $e', isError: true);
      }
    }
  }

  void _showAddFlashcardDialog() {
    _questionController.clear();
    _answerController.clear();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_card,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Novo Flashcard',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'Pergunta',
                  hintText: 'Digite a pergunta do flashcard',
                  prefixIcon: const Icon(Icons.help_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: widget.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[100],
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: 'Resposta',
                  hintText: 'Digite a resposta do flashcard',
                  prefixIcon: const Icon(Icons.check_circle_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: widget.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[100],
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _addFlashcard();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Adicionar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditFlashcardDialog(Flashcard flashcard) {
    _questionController.text = flashcard.question;
    _answerController.text = flashcard.answer;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Editar Flashcard',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'Pergunta',
                  hintText: 'Digite a pergunta do flashcard',
                  prefixIcon: const Icon(Icons.help_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: widget.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[100],
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: 'Resposta',
                  hintText: 'Digite a resposta do flashcard',
                  prefixIcon: const Icon(Icons.check_circle_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: widget.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[100],
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final updatedFlashcard = Flashcard(
                        id: flashcard.id,
                        userId: flashcard.userId,
                        question: _questionController.text.trim(),
                        answer: _answerController.text.trim(),
                        createdAt: flashcard.createdAt,
                      );
                      Navigator.of(context).pop();
                      _updateFlashcard(updatedFlashcard);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Flashcard flashcard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Confirmar Exclusão'),
          ],
        ),
        content: const Text(
          'Tem certeza que deseja deletar este flashcard? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteFlashcard(flashcard);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  void _flipCard() {
    if (_flipController.status == AnimationStatus.completed) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showAnswer = !_showAnswer);
  }

  void _nextCard() {
    setState(() {
      _currentCardIndex = (_currentCardIndex + 1) % _flashcards.length;
      _showAnswer = false;
      _flipController.reset();
    });
  }

  void _previousCard() {
    setState(() {
      _currentCardIndex =
          (_currentCardIndex - 1 + _flashcards.length) % _flashcards.length;
      _showAnswer = false;
      _flipController.reset();
    });
  }

  Widget _buildStudyModeView() {
    if (_flashcards.isEmpty) {
      return _buildEmptyState();
    }

    final currentCard = _flashcards[_currentCardIndex];

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Card ${_currentCardIndex + 1} de ${_flashcards.length}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          final angle = _flipAnimation.value * 3.14159;
                          final isFront = angle < 1.5708;

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: 600,
                                maxHeight: 400,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isFront
                                      ? [
                                          Colors.blue.shade400,
                                          Colors.blue.shade700,
                                        ]
                                      : [
                                          Colors.green.shade400,
                                          Colors.green.shade700,
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..rotateY(isFront ? 0 : 3.14159),
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isFront ? 'PERGUNTA' : 'RESPOSTA',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Expanded(
                                        child: Center(
                                          child: SingleChildScrollView(
                                            child: Text(
                                              isFront
                                                  ? currentCard.question
                                                  : currentCard.answer,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w500,
                                                height: 1.5,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Icon(
                                        isFront
                                            ? Icons.help_outline
                                            : Icons.check_circle_outline,
                                        color: Colors.white70,
                                        size: 32,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'previous',
                onPressed: _previousCard,
                backgroundColor: widget.isDarkMode
                    ? Colors.grey[800]
                    : Colors.white,
                child: Icon(
                  Icons.arrow_back,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              FloatingActionButton.extended(
                heroTag: 'flip',
                onPressed: _flipCard,
                backgroundColor: Colors.blue,
                icon: const Icon(Icons.flip, color: Colors.white),
                label: const Text(
                  'Virar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FloatingActionButton(
                heroTag: 'next',
                onPressed: _nextCard,
                backgroundColor: widget.isDarkMode
                    ? Colors.grey[800]
                    : Colors.white,
                child: Icon(
                  Icons.arrow_forward,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz_outlined,
              size: 80,
              color: Colors.blue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum flashcard encontrado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Crie seu primeiro flashcard para começar a estudar!',
            style: TextStyle(
              fontSize: 14,
              color: widget.isDarkMode ? Colors.white54 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddFlashcardDialog,
            icon: const Icon(Icons.add),
            label: const Text('Criar Flashcard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (_flashcards.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.style, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        '${_flashcards.length} ${_flashcards.length == 1 ? "Flashcard" : "Flashcards"}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => setState(() => _isStudyMode = true),
                icon: const Icon(Icons.school),
                label: const Text('Estudar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadFlashcards,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _flashcards.length,
              itemBuilder: (context, index) {
                final flashcard = _flashcards[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    childrenPadding: const EdgeInsets.all(20),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.quiz, color: Colors.blue),
                    ),
                    title: Text(
                      flashcard.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${flashcard.createdAt.day.toString().padLeft(2, '0')}/${flashcard.createdAt.month.toString().padLeft(2, '0')}/${flashcard.createdAt.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _showEditFlashcardDialog(flashcard),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(flashcard),
                          tooltip: 'Deletar',
                        ),
                      ],
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'RESPOSTA',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              flashcard.answer,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isStudyMode ? 'Modo Estudo' : 'Flashcards',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: _isStudyMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _isStudyMode = false;
                  _flipController.reset();
                  _showAnswer = false;
                }),
                tooltip: 'Voltar',
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _isStudyMode
          ? _buildStudyModeView()
          : _buildListView(),
      floatingActionButton: _isStudyMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddFlashcardDialog,
              icon: const Icon(Icons.add),
              label: const Text('Novo Flashcard'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 12),
              Text('Sair'),
            ],
          ),
          content: const Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) =>
                        LoginPage(isDarkMode: false, onThemeToggle: () {}),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _flipController.dispose();
    super.dispose();
  }
}
