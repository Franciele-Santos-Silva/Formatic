import 'package:flutter/material.dart';
import 'package:formatic/services/auth_service.dart';
import 'package:formatic/services/ai_history_service.dart';
import 'package:formatic/models/ai_history.dart';
import 'widgets/app_top_nav_bar.dart';

class AssistantPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AssistantPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final AiHistoryService _aiHistoryService = AiHistoryService();
  List<AiHistory> _history = [];
  bool _loading = true;
  bool _sendingMessage = false;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);

    try {
      final user = AuthService().currentUser;
      if (user != null) {
        final history = await _aiHistoryService.getUserHistory(user.id);
        setState(
          () => _history = history.reversed.toList(),
        ); // Mais recente primeiro
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar histórico: $e')),
        );
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final question = _messageController.text.trim();
    _messageController.clear();

    setState(() => _sendingMessage = true);

    try {
      final user = AuthService().currentUser;
      if (user == null) return;

      // Simular resposta da AI (em um app real, você faria uma chamada para uma API de AI)
      final simulatedAnswer = _generateSimulatedResponse(question);

      final aiHistory = AiHistory(
        id: 0, // O ID será gerado pelo backend
        userId: user.id,
        question: question,
        answer: simulatedAnswer,
        createdAt: DateTime.now(),
      );

      await _aiHistoryService.addHistory(aiHistory);

      // Adicionar à lista local
      setState(() {
        _history.insert(0, aiHistory);
      });

      // Scroll para baixo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao enviar mensagem: $e')));
      }
    }

    setState(() => _sendingMessage = false);
  }

  String _generateSimulatedResponse(String question) {
    // Respostas simuladas baseadas na pergunta
    final lowercaseQuestion = question.toLowerCase();

    if (lowercaseQuestion.contains('olá') || lowercaseQuestion.contains('oi')) {
      return 'Olá! Como posso ajudar você hoje?';
    } else if (lowercaseQuestion.contains('estudar') ||
        lowercaseQuestion.contains('estudo')) {
      return 'Para estudar de forma eficaz, recomendo: 1) Criar um cronograma de estudos, 2) Fazer pausas regulares, 3) Usar técnicas como flashcards e mapas mentais, 4) Praticar exercícios regularmente.';
    } else if (lowercaseQuestion.contains('flashcard')) {
      return 'Flashcards são uma excelente ferramenta de estudo! Eles funcionam através da repetição espaçada, ajudando na memorização. Você pode criar flashcards na aba dedicada do app.';
    } else if (lowercaseQuestion.contains('como') &&
        lowercaseQuestion.contains('funciona')) {
      return 'Este assistente pode ajudar com dúvidas sobre estudos, técnicas de aprendizado e organização. Faça perguntas específicas para obter respostas mais detalhadas!';
    } else {
      return 'Interessante pergunta! Embora eu seja um assistente simulado, posso ajudar com dicas de estudo e organização. Para respostas mais específicas sobre "$question", recomendo consultar fontes especializadas no assunto.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppTopNavBar(
        title: 'Assistente AI',
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma conversa ainda',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Faça uma pergunta para começar!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final chat = _history[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Pergunta do usuário
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(
                                bottom: 8,
                                left: 50,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B2CF5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                chat.question,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          // Resposta da AI
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(
                                bottom: 16,
                                right: 50,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chat.answer,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${chat.createdAt.hour}:${chat.createdAt.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          // Input de mensagem
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua pergunta...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_sendingMessage,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B2CF5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendingMessage ? null : _sendMessage,
                    icon: _sendingMessage
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
