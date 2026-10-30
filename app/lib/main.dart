import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/landing_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MatchUniversitarioApp());
}

class MatchUniversitarioApp extends StatelessWidget {
  const MatchUniversitarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Match Universitario · Uniguajira',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.light,
        themeMode: ThemeMode.light,
        home: const LandingScreen(),
      ),
    );
  }
}
