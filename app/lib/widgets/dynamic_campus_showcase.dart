import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Modelo de un punto interactivo ("Hotspot / Pin en vivo") sobre una fotografía del campus.
class CampusPhotoHotspot {
  const CampusPhotoHotspot({
    required this.xAlign,
    required this.yAlign,
    required this.badge,
    required this.title,
    required this.detail,
    required this.ctaLabel,
  });

  /// Coordenada relativa horizontal (0.0 izquierda -> 1.0 derecha).
  final double xAlign;

  /// Coordenada relativa vertical (0.0 arriba -> 1.0 abajo).
  final double yAlign;

  final String badge;
  final String title;
  final String detail;
  final String ctaLabel;
}

/// Modelo de cada historia visual del campus en el Landing.
class CampusStoryItem {
  const CampusStoryItem({
    required this.id,
    required this.stepNumber,
    required this.assetPath,
    required this.secondaryAssetPath,
    required this.categoryChip,
    required this.title,
    required this.subtitle,
    required this.locationLabel,
    required this.liveCounterLabel,
    required this.accentColor,
    required this.baseTiltDegrees,
    required this.imageAlignment,
    required this.featureBullets,
    required this.hotspots,
    required this.initialReactions,
  });

  final String id;
  final String stepNumber;
  final String assetPath;
  final String? secondaryAssetPath;
  final String categoryChip;
  final String title;
  final String subtitle;
  final String locationLabel;
  final String liveCounterLabel;
  final Color accentColor;

  /// Ángulo base de inclinación en grados (ej. -3.8° o +3.8°) para dar dinamismo editorial.
  final double baseTiltDegrees;
  final Alignment imageAlignment;
  final List<String> featureBullets;
  final List<CampusPhotoHotspot> hotspots;
  final int initialReactions;
}

const List<CampusStoryItem> kCampusStories = [
  CampusStoryItem(
    id: 'comunidad_uniguajira',
    stepNumber: '01',
    assetPath: 'assets/images/campus_comunidad_uniguajira.jpg',
    secondaryAssetPath: null,
    categoryChip: '🏛️ Comunidad & Semilleros Uniguajira',
    title: 'Encuentros que nacen en el bloque y se vuelven proyectos reales',
    subtitle:
        'Olvídate de buscar equipo salón por salón. En MatchUni publicas tu idea de proyecto de grado, semillero de investigación o grupo de estudio y conectas con estudiantes y docentes de todas las facultades.',
    locationLabel: 'Bloque Académico · Escalera Caracol Uniguajira',
    liveCounterLabel: '+24 estudiantes conectaron aquí hoy',
    accentColor: Color(0xFFEA6A00),
    baseTiltDegrees: -3.6,
    imageAlignment: Alignment(0.0, -0.15),
    initialReactions: 48,
    featureBullets: [
      '🎓 Filtra por carrera, facultad y semestre en segundos',
      '📄 Adjunta guías en PDF, artículos o avances en tu convocatoria',
      '🤝 Haz Match y desbloquea el contacto directo sin intermediarios',
    ],
    hotspots: [
      CampusPhotoHotspot(
        xAlign: 0.48,
        yAlign: 0.22,
        badge: '📍 Escalera Caracol',
        title: 'Escalera Caracol & Galerías del Bloque',
        detail:
            'El punto clásico de reunión antes de entrar a sustentaciones, asesorías de tesis y grupos de estudio.',
        ctaLabel: 'Buscar equipo de proyecto',
      ),
      CampusPhotoHotspot(
        xAlign: 0.46,
        yAlign: 0.68,
        badge: '🤝 +24 en Semilleros',
        title: 'Semilleros y Encuentros Interfacultades',
        detail:
            'Ingeniería, Ciencias Sociales, Educación y Administración trabajando juntos en retos reales de La Guajira.',
        ctaLabel: 'Ver convocatorias activas',
      ),
    ],
  ),
  CampusStoryItem(
    id: 'deporte_5k',
    stepNumber: '02',
    assetPath: 'assets/images/campus_deporte_5k.jpg',
    secondaryAssetPath: null,
    categoryChip: '🏃‍♀️ Bienestar, Deporte 5K & Parches',
    title: 'Mucho más que parciales: arma tu combo para correr 5K y vivir el campus',
    subtitle:
        'La vida universitaria también se vive cruzando la meta de una 5K, entrenando en las tardes o armando parches culturales. Toma fotos desde tu cámara, compártelas en tus Matches y coordina directo por WhatsApp.',
    locationLabel: 'Bienestar Universitario · Carrera Rosa 5K',
    liveCounterLabel: '15 parches deportivos y culturales activos',
    accentColor: Color(0xFFE11D48),
    baseTiltDegrees: 3.6,
    imageAlignment: Alignment(0.0, -0.2),
    initialReactions: 62,
    featureBullets: [
      '📷 Toma foto en vivo con tu cámara o sube imágenes al Match',
      '💬 Contacto directo a WhatsApp o correo institucional en 1 clic',
      '🏅 Parches para running 5K, torneos, ferias y grupos de estudio',
    ],
    hotspots: [
      CampusPhotoHotspot(
        xAlign: 0.36,
        yAlign: 0.22,
        badge: '✌️ Actitud 5K',
        title: 'Parche Runner & Entrenamiento',
        detail:
            'Conecta con estudiantes de otras carreras para entrenar en las tardes y representar a tu facultad.',
        ctaLabel: 'Unirme a un parche',
      ),
      CampusPhotoHotspot(
        xAlign: 0.52,
        yAlign: 0.52,
        badge: '🏅 Meta Cumplida',
        title: 'Carreras, Torneos y Eventos del Campus',
        detail:
            'Publica o inscríbete en actividades deportivas, recreativas y retos de bienestar universitario.',
        ctaLabel: 'Explorar eventos hoy',
      ),
    ],
  ),
];

/// Dúo de fotografías GRANDES y GIRADAS (estilo Polaroid Editorial) que aparece
/// desde la parte superior del Hero y reacciona al scroll y al toque.
class CampusHeroPhotoCapsules extends StatefulWidget {
  const CampusHeroPhotoCapsules({
    super.key,
    required this.onTapStory,
    this.scrollOffset = 0.0,
  });

  final void Function(CampusStoryItem story) onTapStory;
  final double scrollOffset;

  @override
  State<CampusHeroPhotoCapsules> createState() =>
      _CampusHeroPhotoCapsulesState();
}

class _CampusHeroPhotoCapsulesState extends State<CampusHeroPhotoCapsules> {
  int _frontCard = 0;

  @override
  Widget build(BuildContext context) {
    // Oscilación suave del giro mientras el usuario hace scroll por el Landing
    final scrollWave = math.sin(widget.scrollOffset / 160.0) * 0.025;
    final leftAngle = (-0.085 + scrollWave).clamp(-0.14, -0.03);
    final rightAngle = (0.080 - scrollWave).clamp(0.03, 0.14);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 520;
        final stageHeight = isMobile ? 250.0 : 285.0;
        final cardW = isMobile
            ? (constraints.maxWidth * 0.56).clamp(185.0, 240.0)
            : 265.0;
        final cardH = isMobile ? 215.0 : 245.0;

        final card0 = Positioned(
          left: isMobile ? 4 : 12,
          top: 14,
          child: Transform.rotate(
            angle: _frontCard == 0 ? leftAngle * 0.7 : leftAngle,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              scale: _frontCard == 0 ? 1.04 : 0.95,
              child: _HeroTiltedBigCard(
                story: kCampusStories[0],
                width: cardW,
                height: cardH,
                badgeText: '🏛️ Patio & Escalera Uniguajira',
                isFront: _frontCard == 0,
                onTap: () {
                  if (_frontCard != 0) {
                    setState(() => _frontCard = 0);
                  } else {
                    widget.onTapStory(kCampusStories[0]);
                  }
                },
                onZoom: () => widget.onTapStory(kCampusStories[0]),
              ),
            ),
          ),
        );

        final card1 = Positioned(
          right: isMobile ? 4 : 16,
          top: 6,
          child: Transform.rotate(
            angle: _frontCard == 1 ? rightAngle * 0.7 : rightAngle,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              scale: _frontCard == 1 ? 1.04 : 0.95,
              child: _HeroTiltedBigCard(
                story: kCampusStories[1],
                width: cardW,
                height: cardH,
                badgeText: '🏅 Meta 5K · Parches Reales',
                isFront: _frontCard == 1,
                onTap: () {
                  if (_frontCard != 1) {
                    setState(() => _frontCard = 1);
                  } else {
                    widget.onTapStory(kCampusStories[1]);
                  }
                },
                onZoom: () => widget.onTapStory(kCampusStories[1]),
              ),
            ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: stageHeight,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: _frontCard == 0 ? [card1, card0] : [card0, card1],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'Toca cualquiera de las fotos giradas para traerla al frente o hacer Zoom HD',
                    style: TextStyle(
                      color: Color(0xFF6E5D4F),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _HeroTiltedBigCard extends StatelessWidget {
  const _HeroTiltedBigCard({
    required this.story,
    required this.width,
    required this.height,
    required this.badgeText,
    required this.isFront,
    required this.onTap,
    required this.onZoom,
  });

  final CampusStoryItem story;
  final double width;
  final double height;
  final String badgeText;
  final bool isFront;
  final VoidCallback onTap;
  final VoidCallback onZoom;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.fromLTRB(9, 9, 9, 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFront
                ? story.accentColor.withValues(alpha: 0.85)
                : const Color(0xFFDCCFC2),
            width: isFront ? 2.4 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isFront ? 0.18 : 0.10),
              blurRadius: isFront ? 24 : 14,
              offset: Offset(0, isFront ? 10 : 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      story.assetPath,
                      fit: BoxFit.cover,
                      alignment: story.imageAlignment,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                          stops: const [0.55, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: onZoom,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.zoom_out_map_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 7,
                      child: Text(
                        story.liveCounterLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    badgeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1C140D),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Icon(
                  Icons.touch_app_rounded,
                  size: 14,
                  color: story.accentColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Sección narrativa principal del Landing:
/// Muestra las fotografías **GRANDES y GIRADAS (inclinadas con estilo Polaroid Editorial)**
/// acompañando paso a paso la explicación de cómo funciona Match Universitario,
/// más la opción de alternar al Abanico Polaroid 3D.
class DynamicCampusShowcase extends StatefulWidget {
  const DynamicCampusShowcase({
    super.key,
    required this.onExploreBoard,
    this.scrollOffset = 0.0,
  });

  final VoidCallback onExploreBoard;
  final double scrollOffset;

  @override
  State<DynamicCampusShowcase> createState() => _DynamicCampusShowcaseState();
}

class _DynamicCampusShowcaseState extends State<DynamicCampusShowcase> {
  final Map<String, int> _selectedHotspotByStory = {
    for (final s in kCampusStories) s.id: 0,
  };
  final Map<String, int> _reactions = {
    for (final s in kCampusStories) s.id: s.initialReactions,
  };
  final Set<String> _userReacted = {};
  final Set<String> _flippedTilt = {};

  void _toggleReaction(CampusStoryItem item) {
    setState(() {
      if (_userReacted.contains(item.id)) {
        _userReacted.remove(item.id);
        _reactions[item.id] = (_reactions[item.id] ?? item.initialReactions) - 1;
      } else {
        _userReacted.add(item.id);
        _reactions[item.id] = (_reactions[item.id] ?? item.initialReactions) + 1;
      }
    });
  }

  void _togglePhotoTiltDirection(String id) {
    setState(() {
      if (_flippedTilt.contains(id)) {
        _flippedTilt.remove(id);
      } else {
        _flippedTilt.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado de la sección narrativa con fotos giradas
            _buildSectionIntro(isMobile),
            SizedBox(height: isMobile ? 24 : 36),

            // Bloques editoriales en Zig-Zag: Fotos GRANDES y GIRADAS mientras se explica el Landing
            for (var i = 0; i < kCampusStories.length; i++) ...[
              if (i > 0) SizedBox(height: isMobile ? 34 : 52),
              _buildEditorialTiltedStoryBlock(
                context: context,
                story: kCampusStories[i],
                index: i,
                isMobile: isMobile,
                imageOnLeft: i.isEven,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionIntro(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0DB),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFF6C68B)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_enhance_rounded,
                size: 15,
                color: Color(0xFFEA6A00),
              ),
              SizedBox(width: 7),
              Flexible(
                child: Text(
                  ' ASÍ FUNCIONA MATCHUNI · VIDA REAL EN EL CAMPUS',
                  style: TextStyle(
                    color: Color(0xFF9A3412),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Una plataforma pensada para como realmente vives la universidad',
          style: TextStyle(
            color: const Color(0xFF1C140D),
            fontSize: isMobile ? 24 : 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Explora cada foto en grande: toca los pines 📍 sobre la imagen, gírala o ábrela en pantalla completa mientras descubres todo lo que puedes hacer.',
          style: TextStyle(
            color: const Color(0xFF4A3B31),
            fontSize: isMobile ? 14 : 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// Construye cada bloque donde la fotografía aparece **GRANDE y GIRADA (Polaroid Editorial)**
  /// junto a la explicación detallada del Landing.
  Widget _buildEditorialTiltedStoryBlock({
    required BuildContext context,
    required CampusStoryItem story,
    required int index,
    required bool isMobile,
    required bool imageOnLeft,
  }) {
    final photoWidget = _buildBigTiltedPolaroidPhoto(
      context: context,
      story: story,
      index: index,
      isMobile: isMobile,
    );

    final explanationWidget = _buildStoryExplanationColumn(
      context: context,
      story: story,
      isMobile: isMobile,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: photoWidget,
          ),
          const SizedBox(height: 18),
          explanationWidget,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: imageOnLeft
          ? [
              Expanded(flex: 11, child: photoWidget),
              const SizedBox(width: 44),
              Expanded(flex: 10, child: explanationWidget),
            ]
          : [
              Expanded(flex: 10, child: explanationWidget),
              const SizedBox(width: 44),
              Expanded(flex: 11, child: photoWidget),
            ],
    );
  }

  Widget _buildBigTiltedPolaroidPhoto({
    required BuildContext context,
    required CampusStoryItem story,
    required int index,
    required bool isMobile,
  }) {
    final isFlipped = _flippedTilt.contains(story.id);
    final directionMultiplier = isFlipped ? -1.0 : 1.0;

    // Ángulo en radianes (~ -3.6° o +3.6°) + dinamismo suave ligado al scroll del Landing
    final scrollDelta =
        math.sin((widget.scrollOffset / 190.0) + (index * 1.4)) * 0.022;
    final baseRadians =
        (story.baseTiltDegrees * math.pi / 180.0) * directionMultiplier;
    final totalRadians = (baseRadians + scrollDelta).clamp(-0.12, 0.12);

    final activeHotspotIdx = _selectedHotspotByStory[story.id] ?? 0;
    final reactionsCount = _reactions[story.id] ?? story.initialReactions;
    final hasReacted = _userReacted.contains(story.id);
    final photoHeight = isMobile ? 350.0 : 420.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Sombra decorativa secundaria girada en sentido contrario para acentuar el efecto Polaroid
        Positioned.fill(
          child: Transform.rotate(
            angle: -totalRadians * 0.65,
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: story.accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: story.accentColor.withValues(alpha: 0.28),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        // Marco Polaroid GRANDE y GIRADO con la foto real
        AnimatedRotation(
          turns: totalRadians / (2 * math.pi),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          child: GestureDetector(
            onTap: () => _togglePhotoTiltDirection(story.id),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 12 : 16,
                isMobile ? 14 : 18,
                isMobile ? 12 : 16,
                isMobile ? 16 : 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xFFE2D4C5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1C140D).withValues(alpha: 0.14),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fotografía en gran tamaño con pines interactivos
                  SizedBox(
                    height: photoHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            story.assetPath,
                            fit: BoxFit.cover,
                            alignment: story.imageAlignment,
                          ),

                          // Sombreado sutil en bordes para resaltar etiquetas
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.25),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.65),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),

                          // Barra superior dentro de la foto: Chip de categoría + Reacción + Zoom HD
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.94),
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      story.categoryChip,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: story.accentColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => _toggleReaction(story),
                                      borderRadius: BorderRadius.circular(999),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: hasReacted
                                              ? story.accentColor
                                              : Colors.black.withValues(alpha: 0.60),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              '🔥',
                                              style: TextStyle(fontSize: 12.5),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$reactionsCount',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: () => showCampusPhotoLightbox(
                                        context,
                                        story: story,
                                        onExploreBoard: widget.onExploreBoard,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.60),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.zoom_out_map_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Pines interactivos sobre la fotografía grande
                          for (var hIdx = 0; hIdx < story.hotspots.length; hIdx++)
                            _buildInteractiveHotspotPin(
                              story: story,
                              hotspot: story.hotspots[hIdx],
                              hotspotIndex: hIdx,
                              isSelected: activeHotspotIdx == hIdx,
                            ),

                          // Etiqueta inferior sobre la foto con contador en vivo
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: story.accentColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '⚡ ${story.liveCounterLabel}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.60),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.rotate_right_rounded,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Toca para girar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Pie estilo Polaroid con ubicación y botón de Zoom
                  Row(
                    children: [
                      Icon(
                        Icons.place_rounded,
                        size: 16,
                        color: story.accentColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          story.locationLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1C140D),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => showCampusPhotoLightbox(
                          context,
                          story: story,
                          onExploreBoard: widget.onExploreBoard,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: story.accentColor,
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.fullscreen_rounded, size: 18),
                        label: const Text(
                          'Ver grande',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
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

        // Cinta adhesiva / Pin superior estilo collage universitario
        Positioned(
          top: -10,
          child: Transform.rotate(
            angle: -totalRadians * 0.5,
            child: Container(
              width: 96,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0DB).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFF6C68B),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'UNIGUAJIRA #${story.stepNumber}',
                style: const TextStyle(
                  color: Color(0xFF9A3412),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveHotspotPin({
    required CampusStoryItem story,
    required CampusPhotoHotspot hotspot,
    required int hotspotIndex,
    required bool isSelected,
  }) {
    return Align(
      alignment: Alignment(
        (hotspot.xAlign * 2) - 1,
        (hotspot.yAlign * 2) - 1,
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedHotspotByStory[story.id] = hotspotIndex;
          });
        },
        child: AnimatedScale(
          scale: isSelected ? 1.08 : 0.96,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? story.accentColor
                  : Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? Colors.white : story.accentColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.32),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected
                      ? Icons.my_location_rounded
                      : Icons.touch_app_rounded,
                  size: 13,
                  color: isSelected ? Colors.white : story.accentColor,
                ),
                const SizedBox(width: 5),
                Text(
                  hotspot.badge,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1C140D),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Columna explicativa del Landing que acompaña a cada foto grande girada.
  Widget _buildStoryExplanationColumn({
    required BuildContext context,
    required CampusStoryItem story,
    required bool isMobile,
  }) {
    final activeHotspotIdx = _selectedHotspotByStory[story.id] ?? 0;
    final activeHotspot =
        story.hotspots[activeHotspotIdx % story.hotspots.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Número de paso + Etiqueta
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: story.accentColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'PASO ${story.stepNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                story.categoryChip,
                style: TextStyle(
                  color: story.accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Título explicativo grande
        Text(
          story.title,
          style: TextStyle(
            color: const Color(0xFF1C140D),
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.w900,
            height: 1.15,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 10),

        // Párrafo que explica el funcionamiento mientras el usuario ve la foto
        Text(
          story.subtitle,
          style: TextStyle(
            color: const Color(0xFF4A3B31),
            fontSize: isMobile ? 14.5 : 15.5,
            height: 1.48,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Lista de beneficios clave explicados
        for (final bullet in story.featureBullets)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6D8C9)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        color: Color(0xFF1C140D),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 10),

        // Tarjeta interactiva sincronizada con el Pin seleccionado sobre la foto girada
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.place_rounded,
                    size: 16,
                    color: story.accentColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pin activo en la foto: ${activeHotspot.title}',
                      style: const TextStyle(
                        color: Color(0xFF1C140D),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                activeHotspot.detail,
                style: const TextStyle(
                  color: Color(0xFF4A3B31),
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: widget.onExploreBoard,
                    style: FilledButton.styleFrom(
                      backgroundColor: story.accentColor,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 16),
                    label: Text(
                      activeHotspot.ctaLabel,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  for (var i = 0; i < story.hotspots.length; i++)
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: activeHotspotIdx == i
                          ? story.accentColor.withValues(alpha: 0.15)
                          : Colors.white,
                      side: BorderSide(
                        color: activeHotspotIdx == i
                            ? story.accentColor
                            : const Color(0xFFD6C7B8),
                      ),
                      label: Text(
                        story.hotspots[i].badge,
                        style: TextStyle(
                          color: activeHotspotIdx == i
                              ? story.accentColor
                              : const Color(0xFF4A3B31),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedHotspotByStory[story.id] = i;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Modal inmersivo con `InteractiveViewer` (zoom táctil y de rueda) para explorar las fotos en alta definición.
Future<void> showCampusPhotoLightbox(
  BuildContext context, {
  required CampusStoryItem story,
  required VoidCallback onExploreBoard,
}) async {
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920, maxHeight: 720),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C140D),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: story.accentColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            story.categoryChip,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            story.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Center(
                          child: Image.asset(
                            story.assetPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFF291D14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                story.subtitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '📍 ${story.locationLabel} · Usa pellizco o doble clic para hacer zoom',
                                style: const TextStyle(
                                  color: Color(0xFFFED7AA),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            onExploreBoard();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: story.accentColor,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.bolt_rounded, size: 18),
                          label: const Text('Hacer Match'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
