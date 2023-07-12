import 'package:flutter/material.dart';

import 'svg_icon.dart';

class MainPageScaffold extends StatelessWidget {
  const MainPageScaffold({
    super.key,
    required this.onToggleThemeButtonPressed,
    required this.onAboutButtonPressed,
    required this.body,
  });

  final VoidCallback onToggleThemeButtonPressed;
  final VoidCallback onAboutButtonPressed;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = TextSpan(
      text: 'svg2iv | ',
      children: [
        TextSpan(
          text: 'SVG to ImageVector conversion tool',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.useMaterial3 || theme.brightness == Brightness.dark
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(title),
        actions: [
          IconButton(
            onPressed: onToggleThemeButtonPressed,
            icon: const SvgIcon('res/icons/toggle_theme'),
          ),
          IconButton(
            onPressed: onAboutButtonPressed,
            icon: const Icon(Icons.info_outlined),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: body,
    );
  }
}
