import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../state/app_state.dart';
import '../utils/photo_picker.dart';

/// Paletas de portada disponibles para el perfil
const List<List<Color>> kBannerGradients = [
  [Color(0xFFFF5500), Color(0xFFFFAB00)], // Sunset Guajiro
  [Color(0xFFD81B60), Color(0xFFFF6D00)], // Coral Wayuu
  [Color(0xFF00897B), Color(0xFF26C6DA)], // Mar de Riohacha
  [Color(0xFF3949AB), Color(0xFF8E24AA)], // Noche Estudiantil
];

/// Avatares ilustrados predefinidos por si el usuario quiere elegir uno rápido
const List<String> kPresetAvatarEmojis = [
  '👩🏽‍💻',
  '👨🏾‍💻',
  '🎨',
  '🚀',
  '📊',
  '🔬',
  '🌵',
  '⚡',
];

const List<String> kUniguajiraFaculties = [
  'Facultad de Ingeniería',
  'Facultad de Ciencias Económicas y Administrativas',
  'Facultad de Ciencias Sociales y Humanas',
  'Facultad de Ciencias de la Educación',
  'Facultad de Ciencias Básicas y Aplicadas',
];

const List<String> kUniguajiraCampuses = [
  'Sede Riohacha',
  'Sede Maicao',
  'Sede Fonseca',
  'Sede Villanueva',
];

const List<String> kUniguajiraCareers = [
  'Ingeniería de Sistemas',
  'Ingeniería Industrial',
  'Ingeniería Civil',
  'Ingeniería Ambiental',
  'Ingeniería Mecánica',
  'Administración de Empresas',
  'Contaduría Pública',
  'Negocios Internacionales',
  'Diseño Gráfico',
  'Psicología',
  'Trabajo Social',
  'Comunicación Social',
  'Derecho',
  'Licenciatura en Etnoeducación',
  'Biología',
];

const List<String> kAvailabilityOptions = [
  'Buscando equipo de Tesis / Proyecto de Grado',
  'Disponible para Hackathons y Retos',
  'Abierto a Grupos de Estudio',
  'Disponible para Proyectos Interdisciplinarios',
  'Mentor / Par Académico',
];

const List<String> kSuggestedDiplomas = [
  'Diplomado en Desarrollo de Apps con Flutter',
  'Diplomado en Ciencia de Datos e IA',
  'Diplomado en Gerencia de Proyectos (PMI/Scrum)',
  'Diplomado en Diseño UX/UI y Producto Digital',
  'Semillero de Investigación Uniguajira',
  'Diplomado en Finanzas y Emprendimiento',
  'Certificación Cloud / Backend y Bases de Datos',
  'Monitoría Académica Universitaria',
];

const List<String> kSuggestedSkills = [
  'Flutter',
  'Dart',
  'Python',
  'SQL / PostgreSQL',
  'Figma',
  'UI/UX',
  'Node.js',
  'Power BI',
  'Excel Avanzado',
  'Finanzas',
  'Scrum',
  'Oratoria / Pitch',
  'Investigación',
  'Marketing Digital',
];

const List<String> kSuggestedLanguages = [
  'Español',
  'Wayuunaiki',
  'Inglés A2',
  'Inglés B1',
  'Inglés B2',
  'Inglés C1',
  'Portugués',
];

/// Widget reutilizable que muestra la foto subida, avatar emoji o iniciales.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    this.radius = 40,
    this.showBorder = true,
  });

  final UserProfile profile;
  final double radius;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final gradient =
        kBannerGradients[profile.bannerPreset % kBannerGradients.length];
    final hasBytes =
        profile.photoBytes != null && profile.photoBytes!.isNotEmpty;
    final avatarText = profile.avatarUrl?.trim() ?? '';
    final isEmojiPreset =
        avatarText.isNotEmpty && !avatarText.startsWith('http');
    final isNetworkUrl = avatarText.startsWith('http');

    Widget inner;
    if (hasBytes) {
      inner = CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(profile.photoBytes!),
      );
    } else if (isNetworkUrl) {
      inner = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarText),
      );
    } else if (isEmojiPreset) {
      inner = Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          avatarText,
          style: TextStyle(fontSize: radius * 0.95),
        ),
      );
    } else {
      inner = Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          profile.initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: radius * 0.72,
          ),
        ),
      );
    }

    if (!showBorder) return inner;

    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: inner,
    );
  }
}

/// Abre un modal elegante con la vista pública completa de cualquier estudiante.
Future<void> showStudentProfileModal(
  BuildContext context,
  UserProfile profile, {
  bool isCurrentUser = false,
  bool revealContact = false,
  VoidCallback? onEditRequested,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
        child: _StudentProfilePreviewSheet(
          profile: profile,
          isCurrentUser: isCurrentUser,
          revealContact: revealContact,
          onEditRequested: onEditRequested,
        ),
      ),
    ),
  );
}

class _StudentProfilePreviewSheet extends StatelessWidget {
  const _StudentProfilePreviewSheet({
    required this.profile,
    required this.isCurrentUser,
    required this.revealContact,
    this.onEditRequested,
  });

  final UserProfile profile;
  final bool isCurrentUser;
  final bool revealContact;
  final VoidCallback? onEditRequested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final gradient =
        kBannerGradients[profile.bannerPreset % kBannerGradients.length];

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner superior con avatar superpuesto
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 135,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 12,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Uniguajira · ${profile.campus}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton.filledTonal(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -42,
                  left: 24,
                  child: ProfileAvatar(profile: profile, radius: 44),
                ),
                if (isCurrentUser && onEditRequested != null)
                  Positioned(
                    bottom: -36,
                    right: 20,
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onEditRequested!();
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar perfil'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 52),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + insignia verificada
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          profile.name.isEmpty
                              ? 'Estudiante Uniguajira'
                              : profile.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.verified_rounded,
                        size: 22,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                  if (profile.headline.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.headline,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _BadgePill(
                        icon: Icons.school_rounded,
                        text:
                            '${profile.career.isEmpty ? "Programa por definir" : profile.career} · Sem. ${profile.semester}',
                      ),
                      _BadgePill(
                        icon: Icons.account_balance_rounded,
                        text: profile.faculty,
                      ),
                      _BadgePill(
                        icon: Icons.bolt_rounded,
                        text: profile.availability,
                        highlight: true,
                      ),
                    ],
                  ),
                  if (profile.bio.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      profile.bio,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Diplomados, Semilleros y Certificaciones
                  if (profile.diplomas.isNotEmpty) ...[
                    _ModalSectionTitle(
                      icon: Icons.workspace_premium_rounded,
                      title: 'Diplomados, Semilleros y Certificaciones',
                    ),
                    const SizedBox(height: 8),
                    for (final dip in profile.diplomas)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.military_tech_rounded,
                              color: scheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                dip,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                  ],

                  // Habilidades e intereses
                  if (profile.skills.isNotEmpty) ...[
                    const _ModalSectionTitle(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Habilidades & Stack',
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final skill in profile.skills)
                          Chip(
                            label: Text(skill),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Proyectos Destacados
                  if (profile.projects.isNotEmpty) ...[
                    const _ModalSectionTitle(
                      icon: Icons.rocket_launch_rounded,
                      title: 'Proyectos Destacados & Logros',
                    ),
                    const SizedBox(height: 8),
                    for (final proj in profile.projects)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 17,
                              color: scheme.tertiary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                proj,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],

                  // Idiomas y Portafolio
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (profile.languages.isNotEmpty)
                        _BadgePill(
                          icon: Icons.translate_rounded,
                          text: 'Idiomas: ${profile.languages.join(", ")}',
                        ),
                      if (profile.portfolioUrl.isNotEmpty)
                        _BadgePill(
                          icon: Icons.link_rounded,
                          text: profile.portfolioUrl,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Caja de contacto
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (revealContact || isCurrentUser)
                          ? scheme.tertiaryContainer
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (revealContact || isCurrentUser)
                              ? Icons.lock_open_rounded
                              : Icons.lock_outline_rounded,
                          color: (revealContact || isCurrentUser)
                              ? scheme.onTertiaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            (revealContact || isCurrentUser)
                                ? '${profile.contactChannel.label}: ${profile.contactValue.isEmpty ? "Sin definir" : profile.contactValue}'
                                : 'Contacto directo (${profile.contactChannel.label}) protegido. Se revela automáticamente al hacer Match.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalSectionTitle extends StatelessWidget {
  const _ModalSectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.icon,
    required this.text,
    this.highlight = false,
  });

  final IconData icon;
  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: highlight ? scheme.onPrimaryContainer : scheme.primary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: highlight
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Abre el Modal Elegante de Edición / Creación de Perfil con pestañas,
/// subida de foto real desde el computador, diplomados, habilidades y más.
Future<bool> showProfileEditorModal(
  BuildContext context, {
  int initialTab = 0,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 740, maxHeight: 820),
        child: ProfileEditorSheet(initialTab: initialTab),
      ),
    ),
  );
  return saved ?? false;
}

class ProfileEditorSheet extends StatefulWidget {
  const ProfileEditorSheet({
    super.key,
    this.initialTab = 0,
    this.isEmbedded = false,
    this.onSaved,
  });

  final int initialTab;
  final bool isEmbedded;
  final VoidCallback? onSaved;

  @override
  State<ProfileEditorSheet> createState() => _ProfileEditorSheetState();
}

class _ProfileEditorSheetState extends State<ProfileEditorSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController;

  late TextEditingController _name;
  late TextEditingController _headline;
  late TextEditingController _email;
  late TextEditingController _career;
  late TextEditingController _semester;
  late TextEditingController _contact;
  late TextEditingController _bio;
  late TextEditingController _portfolioUrl;

  final _customSkillCtrl = TextEditingController();
  final _customDiplomaCtrl = TextEditingController();
  final _customProjectCtrl = TextEditingController();

  late String _faculty;
  late String _campus;
  late String _availability;
  late ContactChannel _channel;
  late List<String> _skills;
  late List<String> _diplomas;
  late List<String> _projects;
  late List<String> _languages;
  Uint8List? _photoBytes;
  String? _avatarUrl;
  late int _bannerPreset;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
    final appState = context.read<AppState>();
    final u = appState.currentUser;

    _name = TextEditingController(text: u.name);
    _headline = TextEditingController(text: u.headline);
    _email = TextEditingController(text: u.universityEmail);
    _career = TextEditingController(text: u.career);
    _semester = TextEditingController(
      text: appState.hasProfile ? u.semester.toString() : '5',
    );
    _contact = TextEditingController(text: u.contactValue);
    _bio = TextEditingController(text: u.bio);
    _portfolioUrl = TextEditingController(text: u.portfolioUrl);

    _faculty = kUniguajiraFaculties.contains(u.faculty)
        ? u.faculty
        : kUniguajiraFaculties.first;
    _campus = kUniguajiraCampuses.contains(u.campus)
        ? u.campus
        : kUniguajiraCampuses.first;
    _availability = kAvailabilityOptions.contains(u.availability)
        ? u.availability
        : kAvailabilityOptions.first;
    _channel = u.contactChannel;
    _skills = [...u.skills];
    _diplomas = [...u.diplomas];
    _projects = [...u.projects];
    _languages = u.languages.isEmpty ? ['Español'] : [...u.languages];
    _photoBytes = u.photoBytes;
    _avatarUrl = u.avatarUrl;
    _bannerPreset = u.bannerPreset;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _name.dispose();
    _headline.dispose();
    _email.dispose();
    _career.dispose();
    _semester.dispose();
    _contact.dispose();
    _bio.dispose();
    _portfolioUrl.dispose();
    _customSkillCtrl.dispose();
    _customDiplomaCtrl.dispose();
    _customProjectCtrl.dispose();
    super.dispose();
  }

  UserProfile get _previewProfile => UserProfile(
        id: 'me',
        name: _name.text.trim(),
        universityEmail: _email.text.trim(),
        career: _career.text.trim(),
        semester: int.tryParse(_semester.text.trim()) ?? 1,
        skills: _skills,
        contactChannel: _channel,
        contactValue: _contact.text.trim(),
        bio: _bio.text.trim(),
        headline: _headline.text.trim(),
        faculty: _faculty,
        campus: _campus,
        availability: _availability,
        diplomas: _diplomas,
        projects: _projects,
        languages: _languages,
        portfolioUrl: _portfolioUrl.text.trim(),
        photoBytes: _photoBytes,
        avatarUrl: _avatarUrl,
        bannerPreset: _bannerPreset,
      );

  Future<void> _uploadFromDevice() async {
    final bytes = await pickProfileImageBytes();
    if (bytes != null && bytes.isNotEmpty) {
      setState(() {
        _photoBytes = bytes;
        _avatarUrl = null;
      });
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      // Si hay campos requeridos vacíos en la pestaña 1, llevamos al usuario allí
      if (_name.text.trim().isEmpty ||
          _email.text.trim().isEmpty ||
          _career.text.trim().isEmpty) {
        _tabController.animateTo(0);
      } else if (_contact.text.trim().isEmpty) {
        _tabController.animateTo(2);
      }
      return;
    }

    if (_skills.isEmpty) {
      _skills.add('Trabajo en equipo');
    }

    final appState = context.read<AppState>();
    final wasNew = !appState.hasProfile;
    final updated = _previewProfile;
    appState.registerOrUpdateProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasNew
              ? '¡Perfil creado con éxito, ${updated.name}! Ya puedes hacer Match.'
              : '¡Tu perfil de Uniguajira ha sido actualizado!',
        ),
      ),
    );

    if (widget.onSaved != null) {
      widget.onSaved!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final gradient =
        kBannerGradients[_bannerPreset % kBannerGradients.length];

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Cabecera visual del modal con selector de foto y portada
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          ProfileAvatar(
                            profile: _previewProfile,
                            radius: 34,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _uploadFromDevice,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: scheme.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name.text.trim().isEmpty
                                  ? 'Configura tu Perfil Universitario'
                                  : _name.text.trim(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                FilledButton.tonalIcon(
                                  onPressed: _uploadFromDevice,
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        Colors.black.withValues(alpha: 0.35),
                                    foregroundColor: Colors.white,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  icon: const Icon(
                                    Icons.upload_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Subir foto'),
                                ),
                                // Selector de color de portada
                                for (var i = 0;
                                    i < kBannerGradients.length;
                                    i++)
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _bannerPreset = i),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: kBannerGradients[i],
                                        ),
                                        border: Border.all(
                                          color: _bannerPreset == i
                                              ? Colors.white
                                              : Colors.white38,
                                          width: _bannerPreset == i ? 2.5 : 1,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!widget.isEmbedded)
                        IconButton.filledTonal(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.close_rounded),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Selector rápido de avatares ilustrados
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Text(
                              'O elige un avatar:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        for (final emoji in kPresetAvatarEmojis)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () => setState(() {
                                _avatarUrl = emoji;
                                _photoBytes = null;
                              }),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _avatarUrl == emoji
                                      ? Colors.white
                                      : Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Pestañas estructuradas del modal
            Material(
              color: scheme.surfaceContainerLow,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.school_outlined, size: 18),
                    text: '1. Carrera & Sede',
                  ),
                  Tab(
                    icon: Icon(Icons.workspace_premium_outlined, size: 18),
                    text: '2. Diplomados & Skills',
                  ),
                  Tab(
                    icon: Icon(Icons.handshake_outlined, size: 18),
                    text: '3. Match & Contacto',
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildIdentityTab(context),
                  _buildAcademicAndSkillsTab(context),
                  _buildContactAndMatchTab(context),
                ],
              ),
            ),

            // Barra inferior fija con botón de guardar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(color: scheme.outlineVariant),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completitud: ${(_previewProfile.completeness * 100).round()}%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      if (!widget.isEmbedded)
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Guardar mi Perfil'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextFormField(
          controller: _name,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Nombre completo',
            prefixIcon: Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Escribe tu nombre' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _headline,
          decoration: const InputDecoration(
            labelText: 'Titular / Especialidad (cómo te defines)',
            hintText: 'Ej: Desarrollador Flutter · Semillero de IA',
            prefixIcon: Icon(Icons.auto_awesome_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo universitario',
            hintText: 'usuario@uniguajira.edu.co',
            prefixIcon: Icon(Icons.alternate_email_rounded),
            border: OutlineInputBorder(),
          ),
          validator: (v) {
            final t = v?.trim() ?? '';
            if (t.isEmpty) return 'Escribe tu correo';
            if (!t.contains('@')) return 'Correo inválido';
            return null;
          },
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _faculty,
          decoration: const InputDecoration(
            labelText: 'Facultad en Uniguajira',
            prefixIcon: Icon(Icons.account_balance_outlined),
            border: OutlineInputBorder(),
          ),
          items: [
            for (final f in kUniguajiraFaculties)
              DropdownMenuItem(value: f, child: Text(f)),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _faculty = v);
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _career,
          decoration: const InputDecoration(
            labelText: 'Carrera / Programa académico',
            prefixIcon: Icon(Icons.school_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Escribe tu carrera' : null,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in kUniguajiraCareers.take(7))
              ActionChip(
                visualDensity: VisualDensity.compact,
                label: Text(c, style: const TextStyle(fontSize: 12)),
                onPressed: () => setState(() => _career.text = c),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                initialValue: _campus,
                decoration: const InputDecoration(
                  labelText: 'Sede / Campus',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final s in kUniguajiraCampuses)
                    DropdownMenuItem(value: s, child: Text(s)),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _campus = v);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _semester,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Semestre',
                  prefixIcon: Icon(Icons.onetwothree_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = int.tryParse(v?.trim() ?? '');
                  if (n == null || n < 1 || n > 12) return '1 a 12';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicAndSkillsTab(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 1. DIPLOMADOS, SEMILLEROS Y CERTIFICACIONES
        const _ModalSectionTitle(
          icon: Icons.workspace_premium_rounded,
          title: 'Diplomados, Semilleros y Certificaciones',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customDiplomaCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ej: Diplomado en Ciencia de Datos / Semillero IA',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addDiploma(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: _addDiploma,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Añadir'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final sug in kSuggestedDiplomas)
              if (!_diplomas.contains(sug))
                ActionChip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.add, size: 15),
                  label: Text(sug, style: const TextStyle(fontSize: 11.5)),
                  onPressed: () => setState(() => _diplomas.add(sug)),
                ),
          ],
        ),
        if (_diplomas.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final d in _diplomas)
            Card(
              color: scheme.secondaryContainer.withValues(alpha: 0.5),
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                leading: Icon(Icons.military_tech_rounded, color: scheme.primary),
                title: Text(
                  d,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => setState(() => _diplomas.remove(d)),
                ),
              ),
            ),
        ],
        const Divider(height: 28),

        // 2. HABILIDADES Y HERRAMIENTAS
        const _ModalSectionTitle(
          icon: Icons.bolt_rounded,
          title: 'Habilidades & Herramientas',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customSkillCtrl,
                decoration: const InputDecoration(
                  hintText: 'Añadir habilidad (ej: Flutter, Excel, Liderazgo)',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addSkill(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: _addSkill,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Añadir'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final s in _skills)
              InputChip(
                label: Text(s),
                selected: true,
                onDeleted: () => setState(() => _skills.remove(s)),
              ),
            for (final sug in kSuggestedSkills)
              if (!_skills.contains(sug))
                FilterChip(
                  label: Text(sug),
                  selected: false,
                  onSelected: (_) => setState(() => _skills.add(sug)),
                ),
          ],
        ),
        const Divider(height: 28),

        // 3. PROYECTOS DESTACADOS Y LOGROS
        const _ModalSectionTitle(
          icon: Icons.rocket_launch_rounded,
          title: 'Proyectos Destacados o Logros Académicos',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customProjectCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ej: App de Reciclaje / Ganador Feria Innovación',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addProject(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: _addProject,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Añadir'),
            ),
          ],
        ),
        if (_projects.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final p in _projects)
                InputChip(
                  avatar: const Icon(Icons.star_rounded, size: 16),
                  label: Text(p),
                  onDeleted: () => setState(() => _projects.remove(p)),
                ),
            ],
          ),
        ],
        const Divider(height: 28),

        // 4. IDIOMAS
        const _ModalSectionTitle(
          icon: Icons.translate_rounded,
          title: 'Idiomas (incluye lenguas nativas)',
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final lang in kSuggestedLanguages)
              FilterChip(
                label: Text(lang),
                selected: _languages.contains(lang),
                onSelected: (sel) {
                  setState(() {
                    if (sel) {
                      _languages.add(lang);
                    } else if (_languages.length > 1) {
                      _languages.remove(lang);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactAndMatchTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _availability,
          decoration: const InputDecoration(
            labelText: '¿Qué estás buscando ahora en el campus?',
            prefixIcon: Icon(Icons.radar_rounded),
            border: OutlineInputBorder(),
          ),
          items: [
            for (final a in kAvailabilityOptions)
              DropdownMenuItem(value: a, child: Text(a)),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _availability = v);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ContactChannel>(
          initialValue: _channel,
          decoration: const InputDecoration(
            labelText: 'Canal de contacto preferido (al hacer Match)',
            prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
            border: OutlineInputBorder(),
          ),
          items: [
            for (final channel in ContactChannel.values)
              DropdownMenuItem(
                value: channel,
                child: Text(channel.label),
              ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _channel = value);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _contact,
          decoration: const InputDecoration(
            labelText: 'Dato de contacto (WhatsApp o Correo)',
            helperText: 'Solo se revela a las personas con quienes confirmes Match',
            prefixIcon: Icon(Icons.phone_android_rounded),
            border: OutlineInputBorder(),
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Escribe un dato de contacto'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _portfolioUrl,
          decoration: const InputDecoration(
            labelText: 'Enlace a Portafolio / GitHub / LinkedIn / Behance',
            hintText: 'Ej: github.com/mi-usuario',
            prefixIcon: Icon(Icons.link_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bio,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Sobre mí y qué puedo aportar a un equipo',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  void _addDiploma() {
    final v = _customDiplomaCtrl.text.trim();
    if (v.isEmpty) return;
    if (!_diplomas.contains(v)) {
      setState(() => _diplomas.add(v));
    }
    _customDiplomaCtrl.clear();
  }

  void _addSkill() {
    final v = _customSkillCtrl.text.trim();
    if (v.isEmpty) return;
    if (!_skills.contains(v)) {
      setState(() => _skills.add(v));
    }
    _customSkillCtrl.clear();
  }

  void _addProject() {
    final v = _customProjectCtrl.text.trim();
    if (v.isEmpty) return;
    if (!_projects.contains(v)) {
      setState(() => _projects.add(v));
    }
    _customProjectCtrl.clear();
  }
}
