// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:formatic/services/auth_service.dart';
import 'package:formatic/services/flashcard_service.dart';
import 'package:formatic/models/flashcard.dart';

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
  static const Color primaryColor = Color(0xFF8B2CF5);
  static const Color darkBackground = Color(0xFF232B36);
  static const Color darkBackgroundDim = Color(0xFF1B252E);
  List<Flashcard> _flashcards = [];
  String _searchQuery = '';
  bool _loading = true;
  bool _isStudyMode = false;
  int _currentCardIndex = 0;
  bool _showAnswer = false;

  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  bool get _isDarkTheme => Theme.of(context).brightness == Brightness.dark;

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
    // Use o tema atual para detectar modo escuro, evitando depender de widget.isDarkMode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          constraints: const BoxConstraints(maxWidth: 550),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [darkBackground, darkBackgroundDim]
                  : [Colors.white, Colors.grey[50]!],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Novo Flashcard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Crie um novo card de estudo',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Campo Pergunta
              Text(
                'Pergunta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[800]!.withOpacity(0.5)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _questionController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ex: O que é Flutter?',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                    prefixIcon: Icon(
                      Icons.help_outline_rounded,
                      color: primaryColor.withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),

              const SizedBox(height: 20),

              // Campo Resposta
              Text(
                'Resposta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[800]!.withOpacity(0.5)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _answerController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ex: Framework UI multiplataforma do Google',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                    prefixIcon: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: primaryColor.withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),

              const SizedBox(height: 28),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _addFlashcard();
                      },
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: const Text(
                        'Criar Flashcard',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
    // Detecta o modo a partir do tema atual
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          constraints: const BoxConstraints(maxWidth: 550),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [darkBackground, darkBackgroundDim]
                  : [Colors.white, Colors.grey[50]!],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Editar Flashcard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Atualize as informações do card',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Campo Pergunta
              Text(
                'Pergunta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[800]!.withOpacity(0.5)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _questionController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Digite a pergunta do flashcard',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                    prefixIcon: Icon(
                      Icons.help_outline_rounded,
                      color: primaryColor.withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),

              const SizedBox(height: 20),

              // Campo Resposta
              Text(
                'Resposta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[800]!.withOpacity(0.5)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _answerController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Digite a resposta do flashcard',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                    prefixIcon: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: primaryColor.withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),

              const SizedBox(height: 28),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
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
                      icon: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Salvar Alterações',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [darkBackground, darkBackgroundDim]
                  : [Colors.white, Colors.grey[50]!],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone de aviso
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.15),
                      Colors.red.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.2),
                        Colors.red.withOpacity(0.15),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Excluir Flashcard?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Esta ação não pode ser desfeita. O flashcard será permanentemente removido.',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Prévia do flashcard
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          size: 16,
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            flashcard.question,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deleteFlashcard(flashcard);
                        },
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Excluir',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkTheme
              ? const [darkBackground, darkBackgroundDim]
              : [Colors.grey[50]!, Colors.white],
        ),
      ),
      child: Column(
        children: [
          // Header do modo estudo
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: _isDarkTheme
                  ? darkBackground.withOpacity(0.6)
                  : Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      _isStudyMode = false;
                      _flipController.reset();
                      _showAnswer = false;
                    }),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: _isDarkTheme ? Colors.white : Colors.black87,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: _isDarkTheme
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modo Estudo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isDarkTheme ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Card ${_currentCardIndex + 1} de ${_flashcards.length}',
                          style: TextStyle(
                            fontSize: 14,
                            color: _isDarkTheme
                                ? Colors.white60
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${((_currentCardIndex + 1) / _flashcards.length * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Progress bar
          Container(
            height: 4,
            color: _isDarkTheme ? Colors.grey[800] : Colors.grey[200],
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentCardIndex + 1) / _flashcards.length,
              child: Container(color: primaryColor),
            ),
          ),

          // Card área
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
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
                            maxHeight: 500,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..rotateY(isFront ? 0 : 3.14159),
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  // Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isFront
                                              ? Icons.help_outline_rounded
                                              : Icons.lightbulb_outline_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isFront ? 'PERGUNTA' : 'RESPOSTA',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Conteúdo
                                  Expanded(
                                    child: Center(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          isFront
                                              ? currentCard.question
                                              : currentCard.answer,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 26,
                                            fontWeight: FontWeight.w600,
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Ícone indicador
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFront
                                          ? Icons.psychology_rounded
                                          : Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
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
            ),
          ),

          // Controles
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _isDarkTheme
                  ? darkBackground.withOpacity(0.6)
                  : Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botão anterior
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _previousCard,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      iconSize: 28,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                  // Botão virar (principal)
                  ElevatedButton.icon(
                    onPressed: _flipCard,
                    icon: const Icon(Icons.flip_rounded, color: Colors.white),
                    label: const Text(
                      'Virar Card',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  // Botão próximo
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _nextCard,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                      iconSize: 28,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isDarkTheme
              ? const [darkBackground, darkBackgroundDim]
              : [Colors.grey[50]!, Colors.white],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone animado
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    size: 80,
                    color: primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'Nenhum Flashcard Ainda',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _isDarkTheme ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Crie seu primeiro flashcard e comece\nsua jornada de aprendizado!',
                style: TextStyle(
                  fontSize: 16,
                  color: _isDarkTheme ? Colors.white60 : Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Botão de criar
              ElevatedButton.icon(
                onPressed: _showAddFlashcardDialog,
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  'Criar Primeiro Flashcard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Dicas
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isDarkTheme
                      ? darkBackground.withOpacity(0.6)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isDarkTheme
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildTipItem(
                      Icons.lightbulb_outline_rounded,
                      'Estude de forma eficiente',
                      'Use flashcards para memorizar conceitos importantes',
                    ),
                    const SizedBox(height: 16),
                    _buildTipItem(
                      Icons.refresh_rounded,
                      'Revise regularmente',
                      'A repetição espaçada melhora a retenção',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _isDarkTheme ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: _isDarkTheme ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    final bool isDark = _isDarkTheme;
    // Filtro de busca
    final filteredFlashcards = _searchQuery.isEmpty
        ? _flashcards
        : _flashcards
              .where(
                (f) =>
                    f.question.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    f.answer.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();
    final baseTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    if (_flashcards.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [darkBackground, darkBackgroundDim]
              : const [Color(0xFFF6F2FF), Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Barra de pesquisa no topo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black12,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.35)
                        : primaryColor.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por perguntas ou respostas... ',
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black45,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 24,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onChanged: (v) {
                  setState(() {
                    _searchQuery = v;
                  });
                },
              ),
            ),
          ),

          // Header moderno com estatísticas
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meus flashcards',
                  style: TextStyle(
                    color: baseTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total de ${filteredFlashcards.length} ${filteredFlashcards.length == 1 ? "card disponível" : "cards disponíveis"}',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Lista de flashcards com design moderno
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadFlashcards,
              color: primaryColor,
              child: filteredFlashcards.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: isDark
                                ? Colors.white.withOpacity(0.35)
                                : Colors.black26,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum resultado encontrado',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tente ajustar sua busca',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      itemCount: filteredFlashcards.length,
                      itemBuilder: (context, index) {
                        final flashcard = filteredFlashcards[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              iconTheme: const IconThemeData(
                                color: Colors.white,
                              ),
                              textTheme: Theme.of(context).textTheme.apply(
                                bodyColor: Colors.white,
                                displayColor: Colors.white,
                              ),
                            ),
                            child: ExpansionTile(
                              iconColor: Colors.white,
                              collapsedIconColor: Colors.white.withOpacity(
                                0.85,
                              ),
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                20,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.psychology_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                flashcard.question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${flashcard.createdAt.day.toString().padLeft(2, '0')}/${flashcard.createdAt.month.toString().padLeft(2, '0')}/${flashcard.createdAt.year}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              trailing: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      onPressed: () =>
                                          _showEditFlashcardDialog(flashcard),
                                      tooltip: 'Editar',
                                      splashRadius: 24,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_rounded,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 22,
                                      ),
                                      onPressed: () =>
                                          _showDeleteConfirmation(flashcard),
                                      tooltip: 'Deletar',
                                      splashRadius: 24,
                                    ),
                                  ],
                                ),
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 14),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.18,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.lightbulb_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'RESPOSTA',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        flashcard.answer,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.6,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkTheme ? darkBackground : Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _isStudyMode ? _buildStudyModeView() : _buildListView(),
                if (!_isStudyMode && _flashcards.isNotEmpty)
                  _buildBottomButtonsBar(),
              ],
            ),
    );
  }

  // Barra de ações fixa no rodapé: dois botões lado a lado com design moderno
  Widget _buildBottomButtonsBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withOpacity(0.35),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _flashcards.isEmpty
                      ? null
                      : () => setState(() => _isStudyMode = true),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        color: _flashcards.isEmpty
                            ? Colors.white.withOpacity(0.6)
                            : Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Estudar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _flashcards.isEmpty
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _showAddFlashcardDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Novo Card',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Logout agora é tratado pelo AppTopNavBar da HomePage. Método removido.

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _flipController.dispose();
    super.dispose();
  }
}
