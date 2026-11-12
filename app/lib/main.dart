import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/landing_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MatchUniversitarioApp());
}

class _MatchUniScrollBehavior extends MaterialScrollBehavior {
  const _MatchUniScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    );
  }
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
        scrollBehavior: const _MatchUniScrollBehavior(),
        theme: AppTheme.light,
        darkTheme: AppTheme.light,
        themeMode: ThemeMode.light,
        home: const LandingScreen(),
      ),
    );
  }
}
