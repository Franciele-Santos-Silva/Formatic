import 'package:flutter/material.dart';
import 'package:formatic/core/theme/app_theme.dart';

/// Empty state used when the user has no flashcards.
class FlashcardEmptyState extends StatelessWidget {
  const FlashcardEmptyState({
    super.key,
    required this.isDarkMode,
    required this.onCreate,
  });

  final bool isDarkMode;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? const [AppTheme.darkBackground, AppTheme.darkSurface]
              : [Colors.grey.shade50, Colors.white],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all((screenWidth * 0.08).clamp(16.0, 32.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    (screenWidth * 0.08).clamp(16.0, 32.0),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(
                      (screenWidth * 0.06).clamp(12.0, 24.0),
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: (screenHeight * 0.10).clamp(40.0, 80.0),
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: (screenHeight * 0.05).clamp(20.0, 40.0)),
                Text(
                  'Nenhum Flashcard Ainda',
                  style: TextStyle(
                    fontSize: (screenWidth * 0.07).clamp(20.0, 28.0),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: (screenHeight * 0.02).clamp(8.0, 16.0)),
                Text(
                  'Crie seu primeiro flashcard e comece\nsua jornada de aprendizado!',
                  style: TextStyle(
                    fontSize: (screenWidth * 0.04).clamp(13.0, 16.0),
                    color: isDarkMode ? Colors.white60 : Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: (screenHeight * 0.06).clamp(24.0, 48.0)),
                ElevatedButton.icon(
                  onPressed: onCreate,
                  icon: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: (screenWidth * 0.06).clamp(20.0, 24.0),
                  ),
                  label: Text(
                    'Criar Primeiro Flashcard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (screenWidth * 0.04).clamp(14.0, 16.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: (screenWidth * 0.08).clamp(20.0, 32.0),
                      vertical: (screenHeight * 0.025).clamp(12.0, 20.0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                SizedBox(height: (screenHeight * 0.03).clamp(16.0, 24.0)),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: (screenWidth * 0.05).clamp(10.0, 20.0),
                  ),
                  padding: EdgeInsets.all(
                    (screenWidth * 0.05).clamp(12.0, 20.0),
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppTheme.darkBackground.withOpacity(0.6)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _TipItem(
                        icon: Icons.lightbulb_outline_rounded,
                        title: 'Estude de forma eficiente',
                        description:
                            'Use flashcards para memorizar conceitos importantes',
                      ),
                      SizedBox(height: (screenHeight * 0.02).clamp(8.0, 16.0)),
                      const _TipItem(
                        icon: Icons.refresh_rounded,
                        title: 'Revise regularmente',
                        description: 'A repetição espaçada melhora a retenção',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all((screenWidth * 0.03).clamp(8.0, 10.0)),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: (screenWidth * 0.05).clamp(16.0, 20.0),
          ),
        ),
        SizedBox(width: (screenWidth * 0.04).clamp(12.0, 16.0)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: (screenWidth * 0.035).clamp(12.0, 14.0),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: (screenWidth * 0.01).clamp(3.0, 4.0)),
              Text(
                description,
                style: TextStyle(
                  fontSize: (screenWidth * 0.03).clamp(11.0, 12.0),
                  color: isDarkMode ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
