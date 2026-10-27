import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posting.dart';
import '../state/app_state.dart';
import '../widgets/post_card.dart';
import '../widgets/profile_modals.dart';
import 'create_post_screen.dart';
import 'landing_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  PostType? _filter;
  String? _careerFilter;
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _popularCareers = const [
    'Ingeniería de Sistemas',
    'Diseño Gráfico',
    'Administración de Empresas',
    'Ingeniería Industrial',
    'Psicología',
    'Comunicación Social',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Posting> _applyFilters(List<Posting> allPosts) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return allPosts.where((p) {
      if (_filter != null && p.type != _filter) return false;
      if (_careerFilter != null &&
          p.authorCareer != _careerFilter &&
          p.targetCareer != _careerFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchesText = p.title.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.authorName.toLowerCase().contains(query) ||
            p.authorCareer.toLowerCase().contains(query) ||
            (p.targetCareer?.toLowerCase().contains(query) ?? false);
        if (!matchesText) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final allPosts = appState.feed;
    final posts = _applyFilters(allPosts);

    final countEquipo =
        allPosts.where((p) => p.type == PostType.buscaEquipo).length;
    final countEstudio =
        allPosts.where((p) => p.type == PostType.grupoEstudio).length;
    final countEventos =
        allPosts.where((p) => p.type == PostType.evento).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;

        return Scaffold(
          backgroundColor: scheme.surfaceContainerLowest,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: scheme.surface,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tablero de Oportunidades',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: isMobile ? 18 : 20,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Universidad de La Guajira · Campus',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            actions: [
              if (isMobile) ...[
                // En móvil: botón compacto para publicar + menú emergente elegante
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilledButton.tonalIcon(
                    onPressed: () => _openCreatePost(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Publicar'),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (val) {
                    if (val == 'landing') {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LandingScreen(),
                        ),
                      );
                    } else if (val == 'logout') {
                      appState.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Sesión cerrada. Ahora estás como usuario nuevo.',
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'landing',
                      child: Row(
                        children: [
                          Icon(Icons.home_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Ir al Inicio / Landing'),
                        ],
                      ),
                    ),
                    if (appState.hasProfile)
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, size: 20, color: Colors.red),
                            SizedBox(width: 10),
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
                // En escritorio: botones completos visibles
                if (appState.hasProfile)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton.icon(
                      onPressed: () {
                        appState.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Sesión cerrada. Ahora estás explorando como usuario nuevo.',
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.error,
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Cerrar sesión'),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LandingScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.home_outlined, size: 18),
                    label: const Text('Inicio'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FilledButton.icon(
                    onPressed: () => _openCreatePost(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Publicar aviso'),
                  ),
                ),
              ],
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 20,
              vertical: 14,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. AVISO PARA USUARIO NUEVO (ELEGANTE Y COMPACTO)
                    if (!appState.hasProfile)
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_add_rounded,
                                size: 18,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estás explorando como visitante',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Crea tu perfil con carrera y diplomados para postularte.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () => _openProfileModal(context),
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                              ),
                              child: const Text('Crear perfil'),
                            ),
                          ],
                        ),
                      ),

                    // 2. FILTRO POR CATEGORÍA (SCROLL HORIZONTAL NATURAL EN MÓVIL)
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _CategoryFilterPill(
                            emoji: '📋',
                            label: 'Todo',
                            count: allPosts.length,
                            selected: _filter == null,
                            onTap: () => setState(() => _filter = null),
                          ),
                          const SizedBox(width: 8),
                          _CategoryFilterPill(
                            emoji: PostType.buscaEquipo.emoji,
                            label: 'Equipo',
                            count: countEquipo,
                            selected: _filter == PostType.buscaEquipo,
                            onTap: () => setState(
                              () => _filter = PostType.buscaEquipo,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CategoryFilterPill(
                            emoji: PostType.grupoEstudio.emoji,
                            label: 'Estudio',
                            count: countEstudio,
                            selected: _filter == PostType.grupoEstudio,
                            onTap: () => setState(
                              () => _filter = PostType.grupoEstudio,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CategoryFilterPill(
                            emoji: PostType.evento.emoji,
                            label: 'Eventos',
                            count: countEventos,
                            selected: _filter == PostType.evento,
                            onTap: () => setState(
                              () => _filter = PostType.evento,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. BARRA DE BÚSQUEDA Y CARRERAS RÁPIDAS
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.65),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Caja de búsqueda limpia
                          TextField(
                            controller: _searchCtrl,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Buscar proyectos, materias, habilidades...',
                              hintStyle: TextStyle(
                                fontSize: 13.5,
                                color: scheme.onSurfaceVariant,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                size: 20,
                                color: scheme.primary,
                              ),
                              suffixIcon: _searchCtrl.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 18),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() {});
                                      },
                                    ),
                              isDense: true,
                              filled: true,
                              fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Filtros de Carrera en chips horizontales táctiles
                          SizedBox(
                            height: 34,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _CareerChip(
                                  label: 'Todas las carreras',
                                  selected: _careerFilter == null,
                                  onTap: () => setState(() => _careerFilter = null),
                                ),
                                for (final c in _popularCareers)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: _CareerChip(
                                      label: c,
                                      selected: _careerFilter == c,
                                      onTap: () => setState(
                                        () => _careerFilter = (_careerFilter == c ? null : c),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. LISTA DE TARJETAS (1 COLUMNA EN MÓVIL, 2 EN ESCRITORIO)
                    if (posts.isEmpty)
                      _EmptyFeed(onResetFilters: () {
                        setState(() {
                          _filter = null;
                          _careerFilter = null;
                          _searchCtrl.clear();
                        });
                      })
                    else
                      LayoutBuilder(
                        builder: (context, boxConstraints) {
                          final isWide = boxConstraints.maxWidth >= 820;
                          final cardWidth = isWide
                              ? (boxConstraints.maxWidth - 16) / 2
                              : boxConstraints.maxWidth;

                          return Wrap(
                            spacing: 16,
                            runSpacing: 14,
                            children: [
                              for (final post in posts)
                                SizedBox(
                                  width: cardWidth,
                                  child: PostCard(posting: post),
                                ),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _openProfileModal(BuildContext context) {
    return showProfileEditorModal(context);
  }

  Future<void> _openCreatePost(BuildContext context) async {
    final appState = context.read<AppState>();
    if (!appState.hasProfile) {
      final created = await _openProfileModal(context);
      if (!created || !context.mounted) return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
  }
}

class _CategoryFilterPill extends StatelessWidget {
  const _CategoryFilterPill({
    required this.emoji,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEA6A00) : scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFFEA6A00)
                : scheme.outlineVariant.withValues(alpha: 0.65),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : scheme.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareerChip extends StatelessWidget {
  const _CareerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? scheme.primary
                : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({this.onResetFilters});

  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No se encontraron avisos',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Intenta buscar con otras palabras o cambiar de carrera.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            if (onResetFilters != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onResetFilters,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Restablecer filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
