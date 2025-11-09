// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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
  static const _helpyName = 'Helpy';
  static const _systemPrompt =
      'Você é Helpy, a tutora virtual da Formatic focada em apoiar estudantes. '
      'Forneça explicações claras, objetivas e em português, reforce técnicas de organização '
      'e proponha próximas etapas ou exercícios práticos sempre que possível.';

  final List<_ChatMessage> _messages = <_ChatMessage>[];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sendingMessage = false;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _apiKey = dotenv.maybeGet('DEEPSEEK_API_KEY')?.trim();
    _messages.add(
      _ChatMessage(
        author: _MessageAuthor.assistant,
        content:
            'Olá! Sou a $_helpyName, sua tutora virtual. Conte o que você precisa estudar '
            'ou quais dificuldades enfrentou e eu preparo um plano de estudos personalizado.',
      ),
    );
  }

  Future<void> _sendMessage() async {
    final question = _messageController.text.trim();
    if (question.isEmpty || _sendingMessage) return;
    _messageController.clear();

    setState(() {
      _messages.add(
        _ChatMessage(author: _MessageAuthor.user, content: question),
      );
      _sendingMessage = true;
    });
    _scrollToBottom();

    try {
      final reply = await _fetchAssistantReply();

      setState(() {
        _messages.add(
          _ChatMessage(author: _MessageAuthor.assistant, content: reply),
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao falar com a IA: $e')));
      }
    }

    setState(() => _sendingMessage = false);
    _scrollToBottom();
  }

  Future<String> _fetchAssistantReply() async {
    final apiKey = _apiKey ?? dotenv.maybeGet('DEEPSEEK_API_KEY')?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'Configure a variável DEEPSEEK_API_KEY no .env e reinicie o app para usar a $_helpyName.',
      );
    }

    final response = await http.post(
      Uri.parse('https://api.deepseek.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'deepseek-chat',
        'messages': _buildChatPayload(),
        'temperature': 0.7,
        'top_p': 0.8,
      }),
    );

    if (response.statusCode != 200) {
      final body = response.body.isEmpty
          ? 'Sem detalhes adicionais.'
          : response.body;
      throw Exception('Falha (${response.statusCode}): $body');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('Resposta inesperada da IA.');
    }

    final message = choices.first['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw Exception('A IA não retornou conteúdo.');
    }

    return content.trim();
  }

  List<Map<String, String>> _buildChatPayload() {
    return [
      {'role': 'system', 'content': _systemPrompt},
      ..._messages.map(
        (message) => {
          'role': message.author == _MessageAuthor.user ? 'user' : 'assistant',
          'content': message.content,
        },
      ),
    ];
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldColor = theme.scaffoldBackgroundColor;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            itemCount: _messages.length + (_sendingMessage ? 1 : 0),
            itemBuilder: (context, index) {
              final isTypingIndicator =
                  _sendingMessage && index == _messages.length;
              if (isTypingIndicator) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16, right: 50),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2D2A39)
                          : const Color(0xFFE9E9ED),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.white70 : const Color(0xFF8B2CF5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$_helpyName está pensando...',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.85)
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final message = _messages[index];
              final isUser = message.author == _MessageAuthor.user;
              final bubbleColor = isUser
                  ? const Color(0xFF8B2CF5)
                  : (isDark
                        ? const Color.fromARGB(255, 65, 61, 79)
                        : const Color(0xFFE9E9ED));

              return Align(
                alignment: isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 16,
                    left: isUser ? 50 : 0,
                    right: isUser ? 0 : 50,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _buildFormattedMessage(message, isDark: isDark),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? scaffoldColor : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey[300]!,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Digite sua pergunta para $_helpyName...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E1B2A)
                        : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !_sendingMessage,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
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
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

enum _MessageAuthor { user, assistant }

class _ChatMessage {
  final _MessageAuthor author;
  final String content;

  const _ChatMessage({required this.author, required this.content});
}

Widget _buildFormattedMessage(_ChatMessage message, {required bool isDark}) {
  final isUser = message.author == _MessageAuthor.user;
  final baseColor = isUser
      ? Colors.white
      : (isDark ? Colors.white : Colors.black87);
  final baseStyle = TextStyle(fontSize: 16, color: baseColor);

  final pattern = RegExp(r'\*\*([^*]+)\*\*');
  final spans = <TextSpan>[];
  var currentIndex = 0;
  final text = message.content;

  for (final match in pattern.allMatches(text)) {
    if (match.start > currentIndex) {
      spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
    }
    final boldText = match.group(1) ?? '';
    spans.add(
      TextSpan(
        text: boldText,
        style: baseStyle.copyWith(fontWeight: FontWeight.w600),
      ),
    );
    currentIndex = match.end;
  }

  if (currentIndex < text.length) {
    spans.add(TextSpan(text: text.substring(currentIndex)));
  }

  if (spans.isEmpty) {
    spans.add(TextSpan(text: text));
  }

  return RichText(
    text: TextSpan(style: baseStyle, children: spans),
  );
}
