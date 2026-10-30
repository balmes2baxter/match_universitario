import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posting.dart';
import '../state/app_state.dart';
import '../widgets/cloud_and_pwa_modals.dart';
import 'home_shell.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _previewIndex = 0;

  void _enterApp(BuildContext context, {int initialIndex = 0}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeShell(initialIndex: initialIndex),
      ),
    );
  }

  void _nextPreview(int total) {
    if (total == 0) return;
    setState(() {
      _previewIndex = (_previewIndex + 1) % total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final posts = appState.feed;
    final totalPosts = posts.length;
    final totalMatches = appState.campusMatches.length;
    final currentPreview =
        posts.isEmpty ? null : posts[_previewIndex % posts.length];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1140),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 14 : 24,
                      vertical: isMobile ? 14 : 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TopNavBar(
                          hasProfile: appState.hasProfile,
                          userName: appState.currentUser.name,
                          onEnterBoard: () =>
                              _enterApp(context, initialIndex: 0),
                          onEnterProfile: () =>
                              _enterApp(context, initialIndex: 2),
                          onLogout: () {
                            appState.logout();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sesión cerrada. Ahora estás como usuario nuevo.',
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: isMobile ? 24 : 36),

                        // HERO PRINCIPAL (Modo Claro Institucional + Tarjeta interactiva)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 860;
                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 11,
                                    child: _HeroLeftPitch(
                                      totalPosts: totalPosts,
                                      totalMatches: totalMatches,
                                      onStartMatch: () =>
                                          _enterApp(context, initialIndex: 0),
                                      onConfigureProfile: () =>
                                          _enterApp(context, initialIndex: 2),
                                    ),
                                  ),
                                  const SizedBox(width: 40),
                                  Expanded(
                                    flex: 9,
                                    child: _InteractiveMatchDeck(
                                      posting: currentPreview,
                                      currentIndex: _previewIndex,
                                      total: posts.length,
                                      onSkip: () => _nextPreview(posts.length),
                                      onLike: () =>
                                          _enterApp(context, initialIndex: 0),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _HeroLeftPitch(
                                  totalPosts: totalPosts,
                                  totalMatches: totalMatches,
                                  onStartMatch: () =>
                                      _enterApp(context, initialIndex: 0),
                                  onConfigureProfile: () =>
                                      _enterApp(context, initialIndex: 2),
                                ),
                                const SizedBox(height: 28),
                                _InteractiveMatchDeck(
                                  posting: currentPreview,
                                  currentIndex: _previewIndex,
                                  total: posts.length,
                                  onSkip: () => _nextPreview(posts.length),
                                  onLike: () =>
                                      _enterApp(context, initialIndex: 0),
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: isMobile ? 32 : 44),

                        // BENTO GRID EN MODO CLARO
                        _BentoModesRow(
                          onSelectMode: () =>
                              _enterApp(context, initialIndex: 0),
                        ),

                        SizedBox(height: isMobile ? 20 : 28),

                        // BARRA DE MATCHES EN VIVO EN EL CAMPUS
                        _LiveMatchesStrip(
                          onTapMatches: () =>
                              _enterApp(context, initialIndex: 1),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  const _TopNavBar({
    required this.hasProfile,
    required this.userName,
    required this.onEnterBoard,
    required this.onEnterProfile,
    required this.onLogout,
  });

  final bool hasProfile;
  final String userName;
  final VoidCallback onEnterBoard;
  final VoidCallback onEnterProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 820;
        final isTiny = constraints.maxWidth < 380;

        return Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEA6A00).withValues(alpha: 0.45),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/uniguajira_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.school_rounded,
                    color: Color(0xFFEA6A00),
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'MatchUni',
                    style: TextStyle(
                      color: Color(0xFF1C140D),
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (!isTiny)
                    const Text(
                      'Universidad de La Guajira',
                      style: TextStyle(
                        color: Color(0xFFC2410C),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            if (isMobile) ...[
              FilledButton.icon(
                onPressed: onEnterBoard,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEA6A00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.grid_view_rounded, size: 16),
                label: const Text(
                  'Tablero',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF1C140D),
                ),
                onSelected: (val) {
                  if (val == 'profile') {
                    onEnterProfile();
                  } else if (val == 'recover') {
                    showLoginByEmailDialog(context);
                  } else if (val == 'pwa') {
                    showPwaAndCloudModal(context);
                  } else if (val == 'logout') {
                    onLogout();
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(hasProfile ? userName : 'Crear perfil / Soy nuevo'),
                      ],
                    ),
                  ),
                  if (!hasProfile)
                    const PopupMenuItem(
                      value: 'recover',
                      child: Row(
                        children: [
                          Icon(Icons.login_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Ya tengo perfil (entrar con correo)'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'pwa',
                    child: Row(
                      children: [
                        Icon(
                          Icons.install_mobile_rounded,
                          size: 18,
                          color: Color(0xFFEA6A00),
                        ),
                        SizedBox(width: 8),
                        Text('Instalar App en celular / Nube'),
                      ],
                    ),
                  ),
                  if (hasProfile)
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Cerrar sesión',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ] else ...[
              TextButton.icon(
                onPressed: () => showPwaAndCloudModal(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFC2410C),
                ),
                icon: const Icon(Icons.install_mobile_rounded, size: 18),
                label: const Text(
                  'Instalar App / Nube',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (!hasProfile)
                TextButton.icon(
                  onPressed: () => showLoginByEmailDialog(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3E3025),
                  ),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: const Text(
                    'Ya tengo perfil',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              TextButton.icon(
                onPressed: onEnterProfile,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3E3025),
                ),
                icon: const Icon(Icons.person_outline_rounded, size: 18),
                label: Text(
                  hasProfile ? userName : 'Soy nuevo',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (hasProfile) ...[
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: onLogout,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 17),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onEnterBoard,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1C140D),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: const BorderSide(color: Color(0xFFDCCFC2)),
                  ),
                ),
                icon: const Icon(
                  Icons.grid_view_rounded,
                  size: 17,
                  color: Color(0xFFEA6A00),
                ),
                label: const Text(
                  'Tablero',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HeroLeftPitch extends StatelessWidget {
  const _HeroLeftPitch({
    required this.totalPosts,
    required this.totalMatches,
    required this.onStartMatch,
    required this.onConfigureProfile,
  });

  final int totalPosts;
  final int totalMatches;
  final VoidCallback onStartMatch;
  final VoidCallback onConfigureProfile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge institucional claro y legible
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0DB),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFF6C68B)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '$totalPosts convocatorias activas hoy · Uniguajira',
                      style: const TextStyle(
                        color: Color(0xFF9A3412),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 16 : 22),

            // Título en alto contraste para lectura cómoda
            Text(
              'Conecta.\nArma tu parche.\nHaz Match ya.',
              style: TextStyle(
                fontSize: isMobile ? 34 : 54,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1C140D),
                height: 1.08,
                letterSpacing: -1.1,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),

            Text(
              'Encuentra compañeros para proyectos de grado, grupos de estudio o eventos académicos en la Universidad de La Guajira. Un clic y contacto directo por WhatsApp o correo.',
              style: TextStyle(
                color: const Color(0xFF4A3B31),
                fontSize: isMobile ? 15 : 17.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 20 : 28),

            // Botones responsivos para celular y escritorio
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: onStartMatch,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEA6A00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 20),
                    label: const Text('Empieza a hacer Match ya'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: onConfigureProfile,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1C140D),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFD6C7B8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: const Text('Crear perfil rápido'),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 14,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: onStartMatch,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEA6A00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 22),
                    label: const Text('Empieza a hacer Match ya'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onConfigureProfile,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1C140D),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFD6C7B8)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 19),
                    label: const Text('Crear perfil rápido'),
                  ),
                ],
              ),
            SizedBox(height: isMobile ? 20 : 28),

            // Métricas compactas
            Wrap(
              spacing: isMobile ? 16 : 24,
              runSpacing: 10,
              children: [
                _MiniMetric(value: '$totalPosts+', label: 'Avisos activos'),
                _MiniMetric(value: '$totalMatches', label: 'Matches hoy'),
                const _MiniMetric(value: '100%', label: 'Directo a WhatsApp'),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFD95F02),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4A3B31),
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Tarjeta interactiva tipo "Swipe / Match" en modo claro limpio.
class _InteractiveMatchDeck extends StatelessWidget {
  const _InteractiveMatchDeck({
    required this.posting,
    required this.currentIndex,
    required this.total,
    required this.onSkip,
    required this.onLike,
  });

  final Posting? posting;
  final int currentIndex;
  final int total;
  final VoidCallback onSkip;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    if (posting == null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFE6D8C9),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0DB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: Color(0xFFEA6A00),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'El campus está listo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1C140D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sé el primer estudiante en publicar una búsqueda de equipo, grupo de estudio o evento.',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF4A3B31),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onLike,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEA6A00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text(
                      'Ir al Tablero',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final p = posting!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Container(
            key: ValueKey(p.id),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFE6D8C9),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabecera de la tarjeta
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0DB),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFF6C68B)),
                      ),
                      child: Text(
                        '${p.type.emoji} ${p.type.label}',
                        style: const TextStyle(
                          color: Color(0xFF9A3412),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${(currentIndex % math.max(total, 1)) + 1}/$total en vivo',
                      style: const TextStyle(
                        color: Color(0xFF6E5D4F),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Autor
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFEA6A00),
                      child: Text(
                        p.authorName.isNotEmpty ? p.authorName[0] : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.authorName,
                            style: const TextStyle(
                              color: Color(0xFF1C140D),
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            p.authorCareer,
                            style: const TextStyle(
                              color: Color(0xFFC2410C),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Título del aviso
                Text(
                  p.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1C140D),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  p.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4A3B31),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                if (p.targetCareer != null || p.location != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (p.targetCareer != null)
                        _LightTag(
                          icon: Icons.school_rounded,
                          text: 'Busca: ${p.targetCareer!}',
                        ),
                      if (p.location != null)
                        _LightTag(
                          icon: Icons.place_rounded,
                          text: p.location!,
                        ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Botones interactivos
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSkip,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3E3025),
                          backgroundColor: const Color(0xFFFAF6F0),
                          side: const BorderSide(color: Color(0xFFD6C7B8)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text(
                          'Otro aviso',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onLike,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFEA6A00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.favorite_rounded, size: 18),
                        label: const Text(
                          'Me interesa',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LightTag extends StatelessWidget {
  const _LightTag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFC2410C)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF431407),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoModesRow extends StatelessWidget {
  const _BentoModesRow({required this.onSelectMode});

  final VoidCallback onSelectMode;

  @override
  Widget build(BuildContext context) {
    const cards = [
      (
        emoji: '🛠️',
        title: 'Arma tu Equipo',
        subtitle: 'Tesis, semilleros y proyectos entre facultades.',
        accent: Color(0xFFEA6A00),
      ),
      (
        emoji: '📚',
        title: 'Pasa el Parcial',
        subtitle: 'Grupos de estudio hoy en biblioteca o bloque.',
        accent: Color(0xFFD97706),
      ),
      (
        emoji: '🎉',
        title: 'Eventos Campus',
        subtitle: 'Ferias, talleres y conferencias en Uniguajira.',
        accent: Color(0xFFE11D48),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        final width = isWide
            ? (constraints.maxWidth - 32) / 3
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final c in cards)
              SizedBox(
                width: width,
                child: InkWell(
                  onTap: onSelectMode,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE6D8C9)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0DB),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            c.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.title,
                                style: const TextStyle(
                                  color: Color(0xFF1C140D),
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.subtitle,
                                style: const TextStyle(
                                  color: Color(0xFF4A3B31),
                                  fontSize: 13.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: c.accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LiveMatchesStrip extends StatelessWidget {
  const _LiveMatchesStrip({required this.onTapMatches});

  final VoidCallback onTapMatches;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapMatches,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFFFFF7ED),
          border: Border.all(color: const Color(0xFFFED7AA)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.handshake_rounded,
                        color: Color(0xFFEA6A00),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Matches recientes: María (Diseño) 🤝 Alex (Sistemas) · Carlos 🤝 Andrés · Mateo 🤝 Andrés',
                          style: TextStyle(
                            color: Color(0xFF1C140D),
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Ver todos los Matches →',
                      style: TextStyle(
                        color: Color(0xFFC2410C),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Row(
              children: [
                Icon(
                  Icons.handshake_rounded,
                  color: Color(0xFFEA6A00),
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Matches recientes: María (Diseño) 🤝 Alex (Sistemas) · Carlos 🤝 Andrés · Mateo 🤝 Andrés',
                    style: TextStyle(
                      color: Color(0xFF1C140D),
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Ver todos los Matches →',
                  style: TextStyle(
                    color: Color(0xFFC2410C),
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
