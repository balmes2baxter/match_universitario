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
    required this.assetPath,
    required this.secondaryAssetPath,
    required this.categoryChip,
    required this.title,
    required this.subtitle,
    required this.locationLabel,
    required this.liveCounterLabel,
    required this.accentColor,
    required this.imageAlignment,
    required this.hotspots,
    required this.initialReactions,
  });

  final String id;
  final String assetPath;
  final String? secondaryAssetPath;
  final String categoryChip;
  final String title;
  final String subtitle;
  final String locationLabel;
  final String liveCounterLabel;
  final Color accentColor;
  final Alignment imageAlignment;
  final List<CampusPhotoHotspot> hotspots;
  final int initialReactions;
}

const List<CampusStoryItem> kCampusStories = [
  CampusStoryItem(
    id: 'comunidad_uniguajira',
    assetPath: 'assets/images/campus_comunidad_uniguajira.jpg',
    secondaryAssetPath: null,
    categoryChip: '🏛️ Comunidad & Semilleros',
    title: 'Encuentros que nacen en el patio central',
    subtitle:
        'Estudiantes, docentes e investigadores conectando entre bloques para sacar adelante semilleros, ferias y proyectos de grado.',
    locationLabel: 'Bloque Académico · Escalera Caracol Uniguajira',
    liveCounterLabel: '+24 estudiantes conectaron aquí hoy',
    accentColor: Color(0xFFEA6A00),
    imageAlignment: Alignment(0.0, -0.15),
    initialReactions: 48,
    hotspots: [
      CampusPhotoHotspot(
        xAlign: 0.48,
        yAlign: 0.24,
        badge: '📍 Arquitectura Icónica',
        title: 'Escalera Caracol & Galerías del Bloque',
        detail:
            'El punto clásico de reunión antes de entrar a sustentaciones, asesorías de tesis y grupos de estudio.',
        ctaLabel: 'Buscar equipo de proyecto',
      ),
      CampusPhotoHotspot(
        xAlign: 0.46,
        yAlign: 0.64,
        badge: '🤝 Parche Académico',
        title: 'Semilleros y Encuentros Interfacultades',
        detail:
            'Ingeniería, Ciencias Sociales, Educación y Administración trabajando juntos en retos reales de La Guajira.',
        ctaLabel: 'Ver convocatorias activas',
      ),
    ],
  ),
  CampusStoryItem(
    id: 'deporte_5k',
    assetPath: 'assets/images/campus_deporte_5k.jpg',
    secondaryAssetPath: null,
    categoryChip: '🏃‍♀️ Bienestar & Deporte 5K',
    title: 'Arma tu combo para entrenar y cruzar la meta',
    subtitle:
        'En MatchUni no todo es parciales: encuentra compañeros para correr 5K, torneos universitarios y parches de bienestar.',
    locationLabel: 'Bienestar Universitario · Carrera 5K',
    liveCounterLabel: '15 parches deportivos y culturales activos',
    accentColor: Color(0xFFE11D48),
    imageAlignment: Alignment(0.0, -0.2),
    initialReactions: 62,
    hotspots: [
      CampusPhotoHotspot(
        xAlign: 0.36,
        yAlign: 0.24,
        badge: '✌️ Energía Universitaria',
        title: 'Parche Runner & Entrenamiento',
        detail:
            'Conecta con estudiantes de otras carreras para entrenar en las tardes y representar a tu facultad.',
        ctaLabel: 'Unirme a un parche',
      ),
      CampusPhotoHotspot(
        xAlign: 0.52,
        yAlign: 0.52,
        badge: '🏅 Meta 5K Cumplida',
        title: 'Carreras, Torneos y Eventos del Campus',
        detail:
            'Publica o inscríbete en actividades deportivas, recreativas y retos de salud universitaria.',
        ctaLabel: 'Explorar eventos hoy',
      ),
    ],
  ),
  CampusStoryItem(
    id: 'collage_pulso',
    assetPath: 'assets/images/campus_comunidad_uniguajira.jpg',
    secondaryAssetPath: 'assets/images/campus_deporte_5k.jpg',
    categoryChip: '⚡ Pulso Real 360°',
    title: 'Del salón y el semillero a la cancha',
    subtitle:
        'Explora ambas facetas de la vida en Uniguajira: excelencia académica en equipo y parches inolvidables fuera de clase.',
    locationLabel: 'Campus Riohacha · Maicao · Fonseca · Villanueva',
    liveCounterLabel: '100% comunidad real Uniguajira',
    accentColor: Color(0xFFD97706),
    imageAlignment: Alignment(0.1, 0.35),
    initialReactions: 39,
    hotspots: [
      CampusPhotoHotspot(
        xAlign: 0.30,
        yAlign: 0.45,
        badge: '🎓 Cultura + Academia',
        title: 'Conexiones que duran toda la carrera',
        detail:
            'Haz Match con un clic y pasa directo a coordinar por WhatsApp o correo institucional.',
        ctaLabel: 'Crear mi perfil ahora',
      ),
      CampusPhotoHotspot(
        xAlign: 0.72,
        yAlign: 0.35,
        badge: '🚀 +8 Matches Hoy',
        title: 'Equipos formándose en tiempo real',
        detail:
            'Sube fotos, guías en PDF o capturas de tu proyecto directamente en tus convocatorias.',
        ctaLabel: 'Ir al Tablero',
      ),
    ],
  ),
];

/// Tira compacta de cápsulas fotográficas interactivas para el Hero izquierdo.
class CampusHeroPhotoCapsules extends StatelessWidget {
  const CampusHeroPhotoCapsules({
    super.key,
    required this.onTapStory,
  });

  final void Function(CampusStoryItem story) onTapStory;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTapStory(kCampusStories.first),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6D8C9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEA6A00).withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini-polaroids superpuestas con rotación dinámica
            SizedBox(
              width: 82,
              height: 44,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 2,
                    child: Transform.rotate(
                      angle: -0.10,
                      child: _MiniPolaroidThumb(
                        assetPath: kCampusStories[0].assetPath,
                        borderColor: const Color(0xFFEA6A00),
                        onTap: () => onTapStory(kCampusStories[0]),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 34,
                    top: 0,
                    child: Transform.rotate(
                      angle: 0.09,
                      child: _MiniPolaroidThumb(
                        assetPath: kCampusStories[1].assetPath,
                        borderColor: const Color(0xFFE11D48),
                        onTap: () => onTapStory(kCampusStories[1]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Flexible(
                        child: Text(
                          'Comunidad real en Uniguajira',
                          style: TextStyle(
                            color: Color(0xFF1C140D),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Toca las fotos para explorar semilleros y parches 5K →',
                    style: TextStyle(
                      color: Color(0xFFC2410C),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPolaroidThumb extends StatelessWidget {
  const _MiniPolaroidThumb({
    required this.assetPath,
    required this.borderColor,
    required this.onTap,
  });

  final String assetPath;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 42,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/// Modos de visualización dinámica (mucho más allá de un carrusel).
enum ShowcaseViewMode {
  bentoAccordion,
  polaroidFan3D,
}

/// Sección interactiva principal de fotografías del campus en el Landing:
/// Combina:
/// 1. **Mosaico Acordeón 3D con Inclinación (Parallax/Tilt) + Pines Interactivos en Vivo**
/// 2. **Baraja Polaroid 3D en Abanico con Física de Arrastre (Swipe/Flip)**
/// 3. **Reacciones en vivo y Visor Inmersivo con Zoom (`InteractiveViewer`)**
class DynamicCampusShowcase extends StatefulWidget {
  const DynamicCampusShowcase({
    super.key,
    required this.onExploreBoard,
  });

  final VoidCallback onExploreBoard;

  @override
  State<DynamicCampusShowcase> createState() => _DynamicCampusShowcaseState();
}

class _DynamicCampusShowcaseState extends State<DynamicCampusShowcase> {
  ShowcaseViewMode _mode = ShowcaseViewMode.bentoAccordion;
  int _activeIndex = 0;
  int _activeHotspotIndex = 0;
  Offset _pointerOffset = Offset.zero;
  final Map<String, int> _reactions = {
    for (final s in kCampusStories) s.id: s.initialReactions,
  };
  final Set<String> _userReacted = {};

  void _selectStory(int index) {
    if (_activeIndex == index) return;
    setState(() {
      _activeIndex = index;
      _activeHotspotIndex = 0;
      _pointerOffset = Offset.zero;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;

        return Container(
          padding: EdgeInsets.all(isMobile ? 16 : 26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE6D8C9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1C140D).withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabecera con selector de experiencia interactiva
              _buildHeader(isMobile),
              SizedBox(height: isMobile ? 16 : 22),

              // Vista principal según el modo elegido
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 360),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _mode == ShowcaseViewMode.bentoAccordion
                    ? _buildBentoAccordionView(context, isMobile)
                    : _buildPolaroidFan3DView(context, isMobile),
              ),

              const SizedBox(height: 16),

              // Barra inferior interactiva del Hotspot activo + Reacciones + Zoom
              _buildActiveHotspotInspector(context, isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isMobile) {
    final togglePills = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6D8C9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeChipButton(
            selected: _mode == ShowcaseViewMode.bentoAccordion,
            icon: Icons.view_quilt_rounded,
            label: 'Mosaico 3D + Pines',
            onTap: () =>
                setState(() => _mode = ShowcaseViewMode.bentoAccordion),
          ),
          const SizedBox(width: 4),
          _ModeChipButton(
            selected: _mode == ShowcaseViewMode.polaroidFan3D,
            icon: Icons.style_rounded,
            label: 'Abanico Polaroid',
            onTap: () => setState(() => _mode = ShowcaseViewMode.polaroidFan3D),
          ),
        ],
      ),
    );

    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0DB),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFF6C68B)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 13,
                    color: Color(0xFFEA6A00),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'MURAL INTERACTIVO EN VIVO',
                    style: TextStyle(
                      color: Color(0xFF9A3412),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Toca los pines 📍 sobre las fotos',
                style: TextStyle(
                  color: Color(0xFF6E5D4F),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Así se vive el Match en Uniguajira',
          style: TextStyle(
            color: const Color(0xFF1C140D),
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Explora nuestras historias reales: expande cada fotografía, toca los puntos interactivos o cambia al abanico Polaroid 3D.',
          style: TextStyle(
            color: Color(0xFF4A3B31),
            fontSize: 13.5,
            height: 1.35,
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleColumn,
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: togglePills,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: titleColumn),
        const SizedBox(width: 16),
        togglePills,
      ],
    );
  }

  /// MODO 1: Mosaico Acordeón 3D con efecto Parallax y Pines interactivos sobre la imagen.
  Widget _buildBentoAccordionView(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        key: const ValueKey('bento_mobile'),
        children: [
          for (var i = 0; i < kCampusStories.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 340),
              curve: Curves.easeOutCubic,
              height: _activeIndex == i ? 340 : 108,
              child: _buildInteractiveStoryCard(
                context: context,
                story: kCampusStories[i],
                index: i,
                isExpanded: _activeIndex == i,
                isMobile: true,
              ),
            ),
          ],
        ],
      );
    }

    return SizedBox(
      key: const ValueKey('bento_desktop'),
      height: 430,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < kCampusStories.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            Expanded(
              flex: _activeIndex == i ? 16 : 6,
              child: _buildInteractiveStoryCard(
                context: context,
                story: kCampusStories[i],
                index: i,
                isExpanded: _activeIndex == i,
                isMobile: false,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInteractiveStoryCard({
    required BuildContext context,
    required CampusStoryItem story,
    required int index,
    required bool isExpanded,
    required bool isMobile,
  }) {
    final tiltX = isExpanded ? (_pointerOffset.dy * -0.06) : 0.0;
    final tiltY = isExpanded ? (_pointerOffset.dx * 0.06) : 0.0;
    final reactionsCount = _reactions[story.id] ?? story.initialReactions;
    final hasReacted = _userReacted.contains(story.id);

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile && !isExpanded) {
          _selectStory(index);
        }
      },
      onHover: (event) {
        if (!isExpanded) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return;
        final local = event.localPosition;
        final nx = ((local.dx / box.size.width) - 0.5).clamp(-0.5, 0.5);
        final ny = ((local.dy / box.size.height) - 0.5).clamp(-0.5, 0.5);
        setState(() {
          _pointerOffset = Offset(nx, ny);
        });
      },
      onExit: (_) {
        if (_pointerOffset != Offset.zero) {
          setState(() => _pointerOffset = Offset.zero);
        }
      },
      child: GestureDetector(
        onTap: () {
          if (!isExpanded) {
            _selectStory(index);
          } else {
            showCampusPhotoLightbox(
              context,
              story: story,
              onExploreBoard: widget.onExploreBoard,
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(tiltX)
            ..rotateY(tiltY),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isExpanded
                  ? story.accentColor.withValues(alpha: 0.85)
                  : const Color(0xFFDCCFC2),
              width: isExpanded ? 2.2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isExpanded
                    ? story.accentColor.withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: isExpanded ? 22 : 10,
                offset: Offset(0, isExpanded ? 10 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Fotografía principal (o composición dividida si tiene foto secundaria)
                _buildStoryBackgroundPhoto(story, isExpanded),

                // Gradiente de lectura cálido para que los textos siempre sean legibles
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: isExpanded ? 0.22 : 0.35),
                        Colors.transparent,
                        Colors.black.withValues(alpha: isExpanded ? 0.82 : 0.78),
                      ],
                      stops: const [0.0, 0.42, 1.0],
                    ),
                  ),
                ),

                // Píldora superior de categoría + Botón de zoom / reacción
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
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            story.categoryChip,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: story.accentColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _toggleReaction(story),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: hasReacted
                                      ? story.accentColor
                                      : Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '🔥',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$reactionsCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
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
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.open_in_full_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // PINES / HOTSPOTS INTERACTIVOS SOBRE LA FOTOGRAFÍA (cuando está expandida)
                if (isExpanded)
                  for (var hIdx = 0; hIdx < story.hotspots.length; hIdx++)
                    _buildInteractiveHotspotPin(
                      story: story,
                      hotspot: story.hotspots[hIdx],
                      hotspotIndex: hIdx,
                      isSelected: _activeHotspotIndex == hIdx,
                    ),

                // Contenido inferior de la tarjeta
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: story.accentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '⚡ ${story.liveCounterLabel}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              story.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              story.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 12.5,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.place_rounded,
                                  color: Color(0xFFFED7AA),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    story.locationLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFFED7AA),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Text(
                                story.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.unfold_more_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
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
  }

  Widget _buildStoryBackgroundPhoto(CampusStoryItem story, bool isExpanded) {
    final parallaxShift = isExpanded
        ? Offset(_pointerOffset.dx * -16, _pointerOffset.dy * -16)
        : Offset.zero;

    if (story.secondaryAssetPath != null) {
      // Composición diagonal/dividida interactiva de ambas fotografías reales
      return Transform.translate(
        offset: parallaxShift,
        child: Transform.scale(
          scale: isExpanded ? 1.05 : 1.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: Image.asset(
                  story.assetPath,
                  fit: BoxFit.cover,
                  alignment: const Alignment(-0.2, -0.2),
                ),
              ),
              Container(width: 3, color: Colors.white),
              Expanded(
                flex: 5,
                child: Image.asset(
                  story.secondaryAssetPath!,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.0, -0.25),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Transform.translate(
      offset: parallaxShift,
      child: Transform.scale(
        scale: isExpanded ? 1.05 : 1.0,
        child: Image.asset(
          story.assetPath,
          fit: BoxFit.cover,
          alignment: story.imageAlignment,
        ),
      ),
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
          setState(() => _activeHotspotIndex = hotspotIndex);
        },
        child: AnimatedScale(
          scale: isSelected ? 1.07 : 0.96,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? story.accentColor
                  : Colors.white.withValues(alpha: 0.92),
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
                  isSelected ? Icons.my_location_rounded : Icons.touch_app_rounded,
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

  /// MODO 2: Abanico Polaroid 3D interactivo donde las fotos se apilan con rotación real y pueden pasarse al frente.
  Widget _buildPolaroidFan3DView(BuildContext context, bool isMobile) {
    final activeStory = kCampusStories[_activeIndex % kCampusStories.length];
    final leftIndex = (_activeIndex + 1) % kCampusStories.length;
    final rightIndex = (_activeIndex + 2) % kCampusStories.length;

    return GestureDetector(
      key: const ValueKey('polaroid_fan_3d'),
      onHorizontalDragEnd: (details) {
        final vx = details.primaryVelocity ?? 0;
        if (vx < -100) {
          _selectStory((_activeIndex + 1) % kCampusStories.length);
        } else if (vx > 100) {
          _selectStory(
            (_activeIndex - 1 + kCampusStories.length) % kCampusStories.length,
          );
        }
      },
      child: Container(
        height: isMobile ? 390 : 430,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6F0),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE6D8C9)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Polaroid Izquierda en el abanico (-9 grados)
            Transform.translate(
              offset: Offset(isMobile ? -58 : -165, 14),
              child: Transform.rotate(
                angle: -0.14,
                child: Transform.scale(
                  scale: 0.84,
                  child: _PolaroidFrameCard(
                    story: kCampusStories[leftIndex],
                    isFront: false,
                    isMobile: isMobile,
                    reactionsCount:
                        _reactions[kCampusStories[leftIndex].id] ?? 40,
                    onTap: () => _selectStory(leftIndex),
                    onZoom: () => showCampusPhotoLightbox(
                      context,
                      story: kCampusStories[leftIndex],
                      onExploreBoard: widget.onExploreBoard,
                    ),
                  ),
                ),
              ),
            ),

            // Polaroid Derecha en el abanico (+9 grados)
            Transform.translate(
              offset: Offset(isMobile ? 58 : 165, 18),
              child: Transform.rotate(
                angle: 0.14,
                child: Transform.scale(
                  scale: 0.84,
                  child: _PolaroidFrameCard(
                    story: kCampusStories[rightIndex],
                    isFront: false,
                    isMobile: isMobile,
                    reactionsCount:
                        _reactions[kCampusStories[rightIndex].id] ?? 40,
                    onTap: () => _selectStory(rightIndex),
                    onZoom: () => showCampusPhotoLightbox(
                      context,
                      story: kCampusStories[rightIndex],
                      onExploreBoard: widget.onExploreBoard,
                    ),
                  ),
                ),
              ),
            ),

            // Polaroid Central activa al frente
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, anim) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.90, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  ),
                  child: FadeTransition(opacity: anim, child: child),
                );
              },
              child: _PolaroidFrameCard(
                key: ValueKey('front_${activeStory.id}'),
                story: activeStory,
                isFront: true,
                isMobile: isMobile,
                reactionsCount:
                    _reactions[activeStory.id] ?? activeStory.initialReactions,
                onTap: () => _selectStory(
                  (_activeIndex + 1) % kCampusStories.length,
                ),
                onZoom: () => showCampusPhotoLightbox(
                  context,
                  story: activeStory,
                  onExploreBoard: widget.onExploreBoard,
                ),
              ),
            ),

            // Controles flotantes para rotar el abanico Polaroid
            Positioned(
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE6D8C9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _selectStory(
                        (_activeIndex - 1 + kCampusStories.length) %
                            kCampusStories.length,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 16,
                          color: Color(0xFF1C140D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Barajar Polaroid (${_activeIndex + 1}/${kCampusStories.length})',
                      style: const TextStyle(
                        color: Color(0xFF1C140D),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _selectStory(
                        (_activeIndex + 1) % kCampusStories.length,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Color(0xFFEA6A00),
                        ),
                      ),
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

  /// Inspector dinámico inferior que muestra el detalle del Pin / Hotspot seleccionado
  /// y permite saltar directo al Tablero o abrir el visor de foto en pantalla completa.
  Widget _buildActiveHotspotInspector(BuildContext context, bool isMobile) {
    final story = kCampusStories[_activeIndex % kCampusStories.length];
    final hotspot =
        story.hotspots[_activeHotspotIndex % story.hotspots.length];

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHotspotPillsRow(story),
                const SizedBox(height: 10),
                Text(
                  '${hotspot.badge} · ${hotspot.title}',
                  style: const TextStyle(
                    color: Color(0xFF1C140D),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hotspot.detail,
                  style: const TextStyle(
                    color: Color(0xFF4A3B31),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: widget.onExploreBoard,
                        style: FilledButton.styleFrom(
                          backgroundColor: story.accentColor,
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.bolt_rounded, size: 17),
                        label: Text(hotspot.ctaLabel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      onPressed: () => showCampusPhotoLightbox(
                        context,
                        story: story,
                        onExploreBoard: widget.onExploreBoard,
                      ),
                      tooltip: 'Ver foto en grande',
                      icon: const Icon(Icons.zoom_in_rounded, size: 20),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: story.accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.place_rounded,
                    color: story.accentColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${hotspot.badge} · ${hotspot.title}',
                            style: const TextStyle(
                              color: Color(0xFF1C140D),
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildHotspotPillsRow(story),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hotspot.detail,
                        style: const TextStyle(
                          color: Color(0xFF4A3B31),
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                OutlinedButton.icon(
                  onPressed: () => showCampusPhotoLightbox(
                    context,
                    story: story,
                    onExploreBoard: widget.onExploreBoard,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1C140D),
                    side: const BorderSide(color: Color(0xFFD6C7B8)),
                  ),
                  icon: const Icon(Icons.zoom_in_rounded, size: 18),
                  label: const Text('Zoom HD'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: widget.onExploreBoard,
                  style: FilledButton.styleFrom(
                    backgroundColor: story.accentColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: Text(hotspot.ctaLabel),
                ),
              ],
            ),
    );
  }

  Widget _buildHotspotPillsRow(CampusStoryItem story) {
    return Wrap(
      spacing: 6,
      children: [
        for (var i = 0; i < story.hotspots.length; i++)
          InkWell(
            onTap: () => setState(() => _activeHotspotIndex = i),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _activeHotspotIndex == i
                    ? story.accentColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: story.accentColor.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'Pin ${i + 1}',
                style: TextStyle(
                  color: _activeHotspotIndex == i
                      ? Colors.white
                      : story.accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ModeChipButton extends StatelessWidget {
  const _ModeChipButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEA6A00) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? Colors.white : const Color(0xFF4A3B31),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF4A3B31),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolaroidFrameCard extends StatelessWidget {
  const _PolaroidFrameCard({
    super.key,
    required this.story,
    required this.isFront,
    required this.isMobile,
    required this.reactionsCount,
    required this.onTap,
    required this.onZoom,
  });

  final CampusStoryItem story;
  final bool isFront;
  final bool isMobile;
  final int reactionsCount;
  final VoidCallback onTap;
  final VoidCallback onZoom;

  @override
  Widget build(BuildContext context) {
    final cardWidth = isMobile ? 255.0 : 340.0;
    final cardHeight = isMobile ? 320.0 : 355.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isFront
                ? story.accentColor.withValues(alpha: 0.7)
                : const Color(0xFFDCCFC2),
            width: isFront ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isFront ? 0.16 : 0.08),
              blurRadius: isFront ? 24 : 12,
              offset: Offset(0, isFront ? 10 : 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      story.secondaryAssetPath ?? story.assetPath,
                      fit: BoxFit.cover,
                      alignment: story.imageAlignment,
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          story.categoryChip,
                          style: TextStyle(
                            color: story.accentColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    if (isFront)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: onZoom,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.zoom_out_map_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              story.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1C140D),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    story.locationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6E5D4F),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '🔥 $reactionsCount',
                  style: TextStyle(
                    color: story.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
                  // Barra superior del visor
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

                  // Imagen con Zoom libre (InteractiveViewer)
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

                  // Pie del visor con contexto y botón de acción
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
