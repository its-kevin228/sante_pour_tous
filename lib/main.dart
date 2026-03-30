import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'theme/theme_preview_screen.dart';

void main() {
  runApp(const SantePourTousApp());
}

class SantePourTousApp extends StatelessWidget {
  const SantePourTousApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Santé Pour Tous',
      theme: AppTheme.light(),
      home: const ThemePreviewScreen(),
    );
  }
}
