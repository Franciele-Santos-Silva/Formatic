import 'package:flutter/material.dart';
import 'package:formatic/core/theme/app_theme.dart';
import 'package:formatic/models/flashcards/flashcard.dart';

/// Result returned by add/edit dialogs.
class FlashcardFormData {
  const FlashcardFormData({required this.question, required this.answer});

  final String question;
  final String answer;
}

Future<FlashcardFormData?> showFlashcardFormDialog({
  required BuildContext context,
  required bool isDarkMode,
  Flashcard? flashcard,
}) async {
  final questionController = TextEditingController(
    text: flashcard?.question ?? '',
  );
  final answerController = TextEditingController(text: flashcard?.answer ?? '');

  final isEditing = flashcard != null;

  final result = await showDialog<FlashcardFormData>(
    context: context,
    builder: (dialogContext) {
      final screenWidth = MediaQuery.of(dialogContext).size.width;
      final dialogPadding = screenWidth * 0.05;
      final maxWidth = screenWidth > 600 ? 550.0 : screenWidth * 0.9;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(dialogPadding.clamp(16, 28)),
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? const [AppTheme.darkBackground, AppTheme.darkSurface]
                  : [Colors.white, Colors.grey.shade50],
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
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.028),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_rounded : Icons.add_rounded,
                      color: Colors.white,
                      size: screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Editar Flashcard' : 'Novo Flashcard',
                          style: TextStyle(
                            fontSize: (screenWidth * 0.05).clamp(18, 22),
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenWidth * 0.008),
                        Text(
                          isEditing
                              ? 'Atualize as informações do card'
                              : 'Crie um novo card de estudo',
                          style: TextStyle(
                            fontSize: (screenWidth * 0.032).clamp(12, 14),
                            color: isDarkMode
                                ? Colors.white60
                                : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.055),
              Text(
                'Pergunta',
                style: TextStyle(
                  fontSize: (screenWidth * 0.032).clamp(12, 14),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: screenWidth * 0.018),
              _FormField(
                controller: questionController,
                hint: 'Ex: O que é Flutter?',
                icon: Icons.help_outline_rounded,
                maxLines: 3,
                isDarkMode: isDarkMode,
                screenWidth: screenWidth,
              ),
              SizedBox(height: screenWidth * 0.045),
              Text(
                'Resposta',
                style: TextStyle(
                  fontSize: (screenWidth * 0.032).clamp(12, 14),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: screenWidth * 0.018),
              _FormField(
                controller: answerController,
                hint: 'Ex: Framework UI multiplataforma',
                icon: Icons.lightbulb_outline_rounded,
                maxLines: 4,
                isDarkMode: isDarkMode,
                screenWidth: screenWidth,
              ),
              SizedBox(height: screenWidth * 0.055),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDarkMode
                              ? Colors.white24
                              : Colors.grey[300]!,
                          width: 1.2,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.03,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: (screenWidth * 0.034).clamp(13, 15),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.025),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (questionController.text.trim().isEmpty ||
                            answerController.text.trim().isEmpty) {
                          return;
                        }
                        Navigator.of(dialogContext).pop(
                          FlashcardFormData(
                            question: questionController.text.trim(),
                            answer: answerController.text.trim(),
                          ),
                        );
                      },
                      icon: Icon(
                        isEditing ? Icons.check_rounded : Icons.add_rounded,
                        color: Colors.white,
                        size: (screenWidth * 0.045).clamp(18, 22),
                      ),
                      label: Text(
                        isEditing ? 'Salvar' : 'Criar Flashcard',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: (screenWidth * 0.034).clamp(13, 15),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.03,
                        ),
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
      );
    },
  );

  questionController.dispose();
  answerController.dispose();
  return result;
}

Future<bool> showFlashcardDeleteDialog({
  required BuildContext context,
  required Flashcard flashcard,
  required bool isDarkMode,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final screenWidth = MediaQuery.of(dialogContext).size.width;
      final screenHeight = MediaQuery.of(dialogContext).size.height;
      final dialogPadding = (screenWidth * 0.055).clamp(18.0, 28.0);
      final maxWidth = screenWidth > 500 ? 450.0 : screenWidth * 0.9;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(dialogPadding),
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: screenHeight * 0.8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? const [AppTheme.darkBackground, AppTheme.darkSurface]
                  : [Colors.white, Colors.grey.shade50],
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    (screenWidth * 0.04).clamp(14.0, 20.0),
                  ),
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
                    padding: EdgeInsets.all(
                      (screenWidth * 0.032).clamp(12.0, 16.0),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.2),
                          Colors.red.withOpacity(0.15),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                      size: (screenWidth * 0.1).clamp(36.0, 48.0),
                    ),
                  ),
                ),
                SizedBox(height: (screenHeight * 0.02).clamp(16.0, 24.0)),
                Text(
                  'Excluir Flashcard?',
                  style: TextStyle(
                    fontSize: (screenWidth * 0.055).clamp(18.0, 24.0),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: (screenHeight * 0.012).clamp(8.0, 12.0)),
                Text(
                  'Esta ação não pode ser desfeita. O flashcard será permanentemente removido.',
                  style: TextStyle(
                    fontSize: (screenWidth * 0.035).clamp(13.0, 15.0),
                    color: isDarkMode ? Colors.white60 : Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: (screenHeight * 0.022).clamp(16.0, 28.0)),
                Container(
                  padding: EdgeInsets.all(
                    (screenWidth * 0.032).clamp(12.0, 16.0),
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.help_outline_rounded,
                        size: (screenWidth * 0.038).clamp(14.0, 16.0),
                        color: isDarkMode ? Colors.white60 : Colors.grey[600],
                      ),
                      SizedBox(width: (screenWidth * 0.018).clamp(6.0, 8.0)),
                      Expanded(
                        child: Text(
                          flashcard.question,
                          style: TextStyle(
                            fontSize: (screenWidth * 0.034).clamp(12.0, 14.0),
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (screenHeight * 0.022).clamp(16.0, 28.0)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDarkMode
                                ? Colors.white24
                                : Colors.grey[300]!,
                            width: 1.2,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: (screenWidth * 0.032).clamp(12.0, 16.0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: (screenWidth * 0.035).clamp(13.0, 15.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: (screenWidth * 0.025).clamp(8.0, 12.0)),
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
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          icon: Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                            size: (screenWidth * 0.045).clamp(16.0, 20.0),
                          ),
                          label: Text(
                            'Excluir',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: (screenWidth * 0.035).clamp(13.0, 15.0),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              vertical: (screenWidth * 0.032).clamp(12.0, 16.0),
                            ),
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
    },
  );

  return result ?? false;
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.maxLines,
    required this.isDarkMode,
    required this.screenWidth,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final bool isDarkMode;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[800]!.withOpacity(0.5)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: (screenWidth * 0.034).clamp(13, 15),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white38 : Colors.grey,
            fontSize: (screenWidth * 0.034).clamp(13, 15),
          ),
          prefixIcon: Icon(
            icon,
            color: AppTheme.primaryColor.withOpacity(0.7),
            size: (screenWidth * 0.05).clamp(20, 24),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.032,
            vertical: screenWidth * 0.028,
          ),
        ),
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}
