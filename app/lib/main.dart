import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'state/app_state.dart';

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
        title: 'Match Universitario',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
        ),
        home: const HomeShell(),
      ),
    );
  }
}
