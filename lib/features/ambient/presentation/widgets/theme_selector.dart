import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_manager.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return PopupMenuButton<String>(
          icon: Icon(
            Icons.palette,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onSelected: (themeName) {
            themeManager.setTheme(themeName);
          },
          itemBuilder: (context) => themeManager.availableThemes.map((theme) {
            return PopupMenuItem<String>(
              value: theme,
              child: Row(
                children: [
                  Icon(
                    _getThemeIcon(theme),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(theme.toUpperCase()),
                  if (theme == themeManager.currentThemeName) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  IconData _getThemeIcon(String theme) {
    switch (theme) {
      case 'default':
        return Icons.brightness_auto;
      case 'dark':
        return Icons.dark_mode;
      case 'light':
        return Icons.light_mode;
      case 'ambient':
        return Icons.nights_stay;
      default:
        return Icons.palette;
    }
  }
}
