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

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  int _previewIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
      backgroundColor: const Color(0xFF0D0907),
      body: Stack(
        children: [
          // Fondos luminosos animados tipo "Sunset Guajiro"
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final t = _pulseController.value;
              return Stack(
                children: [
                  Positioned(
                    top: -120 + (t * 30),
                    left: -80 + (t * 20),
                    child: _GlowOrb(
                      size: 420,
                      color: const Color(0xFFFF5E00).withValues(alpha: 0.28),
                    ),
                  ),
                  Positioned(
                    top: 160 - (t * 25),
                    right: -100,
                    child: _GlowOrb(
                      size: 380,
                      color: const Color(0xFFFFB300).withValues(alpha: 0.20),
                    ),
                  ),
                  Positioned(
                    bottom: -140,
                    left: 180,
                    child: _GlowOrb(
                      size: 360,
                      color: const Color(0xFFFF2A54).withValues(alpha: 0.16),
                    ),
                  ),
                ],
              );
            },
          ),

          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1140),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
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
                        ),
                        const SizedBox(height: 36),

                        // HERO PRINCIPAL (Texto corto + Tarjeta interactiva en vivo)
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
                                const SizedBox(height: 32),
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

                        const SizedBox(height: 44),

                        // BENTO GRID ULTRA VISUAL (Sin ladrillos de texto)
                        _BentoModesRow(
                          onSelectMode: () =>
                              _enterApp(context, initialIndex: 0),
                        ),

                        const SizedBox(height: 28),

                        // BARRA DE MATCHES EN VIVO EN EL CAMPUS
                        _LiveMatchesStrip(
                          onTapMatches: () =>
                              _enterApp(context, initialIndex: 1),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
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
  });

  final bool hasProfile;
  final String userName;
  final VoidCallback onEnterBoard;
  final VoidCallback onEnterProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6D00), Color(0xFFFFAB00)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6D00).withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MatchUni',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Universidad de La Guajira',
                style: TextStyle(
                  color: Color(0xFFFFAB40),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onEnterProfile,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white70,
          ),
          icon: const Icon(Icons.person_outline_rounded, size: 18),
          label: Text(hasProfile ? userName : 'Soy nuevo'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: onEnterBoard,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
            ),
          ),
          icon: const Icon(Icons.grid_view_rounded, size: 17),
          label: const Text('Tablero'),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge luminoso en vivo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6D00).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFFF8F00).withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$totalPosts convocatorias activas hoy · Uniguajira',
                style: const TextStyle(
                  color: Color(0xFFFFCC80),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Título gigante con alto impacto visual y pocas palabras
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFFFE0B2),
              Color(0xFFFF9100),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Conecta.\nArma tu parche.\nHaz Match ya.',
            style: TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.05,
              letterSpacing: -1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Encuentra equipo para tesis, estudio o eventos en la Universidad de La Guajira. Un clic y directo al WhatsApp.',
          style: TextStyle(
            color: Color(0xFFBDB6B0),
            fontSize: 17,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),

        // Botones de acción con brillo
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5500), Color(0xFFFF9E00)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6D00).withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: onStartMatch,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                icon: const Icon(Icons.bolt_rounded, size: 22),
                label: const Text('Empieza a hacer Match ya'),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onConfigureProfile,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
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
        const SizedBox(height: 28),

        // Métricas compactas tipo píldora
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _MiniMetric(value: '$totalPosts+', label: 'Avisos activos'),
            _MiniMetric(value: '$totalMatches', label: 'Matches hoy'),
            const _MiniMetric(value: '100%', label: 'Directo a WhatsApp'),
          ],
        ),
      ],
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
            color: Color(0xFFFFAB40),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Tarjeta interactiva tipo "Swipe / Match" para probar desde el mismo Landing.
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Tarjeta trasera decorativa inclinada
            Transform.rotate(
              angle: 0.045,
              child: Container(
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.14),
                  border: Border.all(
                    color: const Color(0xFFFF9100).withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: -0.03,
              child: Container(
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),

            // Tarjeta activa animada
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1.0).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Container(
                key: ValueKey(p.id),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF211610), Color(0xFF17100C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0xFFFF8F00).withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
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
                            color: const Color(0xFFFF6D00).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${p.type.emoji} ${p.type.label}',
                            style: const TextStyle(
                              color: Color(0xFFFFAB40),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${(currentIndex % math.max(total, 1)) + 1}/$total en vivo',
                          style: const TextStyle(
                            color: Colors.white54,
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
                          backgroundColor: const Color(0xFFFF6D00),
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
                                  color: Color(0xFFFFCC80),
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
                        color: Colors.white70,
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

                    // Botones interactivos tipo Tinder/Match
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onSkip,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
                              backgroundColor: const Color(0xFFFF5500),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
          ],
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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFFAB40)),
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
        accent: Color(0xFFFF6D00),
      ),
      (
        emoji: '📚',
        title: 'Pasa el Parcial',
        subtitle: 'Grupos de estudio hoy en biblioteca o bloque.',
        accent: Color(0xFFFFAB00),
      ),
      (
        emoji: '🎉',
        title: 'Eventos Campus',
        subtitle: 'Ferias, talleres y parches en Uniguajira.',
        accent: Color(0xFFFF3D57),
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
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white.withValues(alpha: 0.045),
                      border: Border.all(
                        color: c.accent.withValues(alpha: 0.32),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: c.accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            c.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.subtitle,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
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
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF6D00).withValues(alpha: 0.16),
              const Color(0xFFFFAB00).withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFFF9100).withValues(alpha: 0.3),
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.handshake_rounded,
                  color: Color(0xFFFFAB40),
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Flexible(
                  child: Text(
                    'Matches recientes: María (Diseño) 🤝 Alex (Sistemas) · Carlos 🤝 Andrés · Mateo 🤝 Andrés',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Ver todos los Matches →',
              style: TextStyle(
                color: Color(0xFFFFAB40),
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
