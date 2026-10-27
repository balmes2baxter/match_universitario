import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posting.dart';
import '../state/app_state.dart';
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
      backgroundColor: const Color(0xFF14110F),
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
                          onEnterBoard: () => _enterApp(context, initialIndex: 0),
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

                        // HERO PRINCIPAL (Colores sólidos estáticos + Tarjeta interactiva)
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

                        // BENTO GRID CON COLORES ESTÁTICOS
                        _BentoModesRow(
                          onSelectMode: () => _enterApp(context, initialIndex: 0),
                        ),

                        SizedBox(height: isMobile ? 20 : 28),

                        // BARRA DE MATCHES EN VIVO EN EL CAMPUS
                        _LiveMatchesStrip(
                          onTapMatches: () => _enterApp(context, initialIndex: 1),
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
        final isMobile = constraints.maxWidth < 600;
        final isTiny = constraints.maxWidth < 380;

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEA6A00),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (!isTiny)
                    const Text(
                      'Uniguajira',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (isMobile) ...[
              // En móvil: botón de acceso directo a tablero + menú de opciones
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
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                onSelected: (val) {
                  if (val == 'profile') {
                    onEnterProfile();
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
                  if (hasProfile)
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              ),
            ] else ...[
              TextButton.icon(
                onPressed: onEnterProfile,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD6D1CD),
                ),
                icon: const Icon(Icons.person_outline_rounded, size: 18),
                label: Text(hasProfile ? userName : 'Soy nuevo'),
              ),
              if (hasProfile) ...[
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: onLogout,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF87171),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 17),
                  label: const Text('Cerrar sesión'),
                ),
              ],
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onEnterBoard,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF26201D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: const BorderSide(color: Color(0xFF3A312C)),
                  ),
                ),
                icon: const Icon(Icons.grid_view_rounded, size: 17),
                label: const Text('Tablero'),
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
            // Badge sólido estático
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF241D19),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF3D312A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '$totalPosts convocatorias activas hoy · Uniguajira',
                      style: const TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 16 : 22),

            // Título adaptable
            Text(
              'Conecta.\nArma tu parche.\nHaz Match ya.',
              style: TextStyle(
                fontSize: isMobile ? 34 : 54,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.08,
                letterSpacing: -1.2,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),

            Text(
              'Encuentra equipo para tesis, estudio o eventos en la Universidad de La Guajira. Un clic y directo al WhatsApp.',
              style: TextStyle(
                color: const Color(0xFFB8B0A8),
                fontSize: isMobile ? 14.5 : 17,
                height: 1.4,
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
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF1F1A17),
                      side: const BorderSide(color: Color(0xFF3A312C)),
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
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF1F1A17),
                      side: const BorderSide(color: Color(0xFF3A312C)),
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
            color: Color(0xFFF59E0B),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD6D1CD),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Tarjeta interactiva tipo "Swipe / Match" con colores sólidos y limpios.
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
    if (posting == null) return const SizedBox.shrink();
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
              color: const Color(0xFF1E1916),
              border: Border.all(
                color: const Color(0xFF382E29),
                width: 1.5,
              ),
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
                        color: const Color(0xFF2E2218),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFF573B22)),
                      ),
                      child: Text(
                        '${p.type.emoji} ${p.type.label}',
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${(currentIndex % math.max(total, 1)) + 1}/$total en vivo',
                      style: const TextStyle(
                        color: Color(0xFF9E958E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            p.authorCareer,
                            style: const TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
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
                    color: Colors.white,
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
                    color: Color(0xFFB8B0A8),
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),

                if (p.targetCareer != null || p.location != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (p.targetCareer != null)
                        _DarkTag(
                          icon: Icons.school_rounded,
                          text: 'Busca: ${p.targetCareer!}',
                        ),
                      if (p.location != null)
                        _DarkTag(
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
                          foregroundColor: const Color(0xFFD6D1CD),
                          backgroundColor: const Color(0xFF26201D),
                          side: const BorderSide(color: Color(0xFF3A312C)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Otro aviso'),
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
                        label: const Text('Me interesa'),
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

class _DarkTag extends StatelessWidget {
  const _DarkTag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF28221E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3A312C)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFF59E0B)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
        subtitle: 'Tesis, semilleros y hackathons entre facultades.',
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
        subtitle: 'Ferias, talleres y parches en Uniguajira.',
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
                      color: const Color(0xFF1E1916),
                      border: Border.all(color: const Color(0xFF332B26)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A221E),
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
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.subtitle,
                                style: const TextStyle(
                                  color: Color(0xFFB8B0A8),
                                  fontSize: 13,
                                  height: 1.3,
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
          color: const Color(0xFF1E1916),
          border: Border.all(color: const Color(0xFF382E29)),
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
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Matches recientes: María (Diseño) 🤝 Alex (Sistemas) · Carlos 🤝 Andrés · Mateo 🤝 Andrés',
                          style: TextStyle(
                            color: Colors.white,
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
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                const Icon(
                  Icons.handshake_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Matches recientes: María (Diseño) 🤝 Alex (Sistemas) · Carlos 🤝 Andrés · Mateo 🤝 Andrés',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Ver todos los Matches →',
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
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
