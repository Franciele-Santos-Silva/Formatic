import 'package:flutter/material.dart';
import 'package:formatic/core/theme/app_theme.dart';

/// Bottom bar actions for list mode.
class FlashcardBottomBar extends StatelessWidget {
  const FlashcardBottomBar({
    super.key,
    required this.onStudy,
    required this.onCreate,
    required this.isStudyDisabled,
  });

  final VoidCallback onStudy;
  final VoidCallback onCreate;
  final bool isStudyDisabled;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonHeight = (screenWidth * 0.12).clamp(48.0, 56.0);
    final iconSize = (screenWidth * 0.045).clamp(18.0, 22.0);
    final fontSize = (screenWidth * 0.038).clamp(14.0, 16.0);
    final spacing = (screenWidth * 0.018).clamp(6.0, 10.0);
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: isStudyDisabled ? null : onStudy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    disabledBackgroundColor: AppTheme.primaryColor.withOpacity(
                      0.35,
                    ),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        color: isStudyDisabled
                            ? Colors.white.withOpacity(0.6)
                            : Colors.white,
                        size: iconSize,
                      ),
                      SizedBox(width: spacing),
                      Flexible(
                        child: Text(
                          'Estudar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                            color: isStudyDisabled
                                ? Colors.white.withOpacity(0.6)
                                : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: onCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      SizedBox(width: spacing),
                      Flexible(
                        child: Text(
                          'Novo Card',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
}
