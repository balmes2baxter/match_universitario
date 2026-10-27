import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../state/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.popOnSave = false});

  final bool popOnSave;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _career;
  late TextEditingController _semester;
  late TextEditingController _skills;
  late TextEditingController _contact;
  late TextEditingController _bio;
  late ContactChannel _channel;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    _name = TextEditingController(text: user.name);
    _email = TextEditingController(text: user.universityEmail);
    _career = TextEditingController(text: user.career);
    _semester = TextEditingController(
      text: appState.hasProfile ? user.semester.toString() : '',
    );
    _skills = TextEditingController(text: user.skills.join(', '));
    _contact = TextEditingController(text: user.contactValue);
    _bio = TextEditingController(text: user.bio);
    _channel = user.contactChannel;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _career.dispose();
    _semester.dispose();
    _skills.dispose();
    _contact.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();
    final wasNewUser = !appState.hasProfile;
    final current = appState.currentUser;
    final updated = current.copyWith(
      name: _name.text.trim(),
      universityEmail: _email.text.trim(),
      career: _career.text.trim(),
      semester: int.tryParse(_semester.text.trim()) ?? current.semester,
      skills: _skills.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      contactChannel: _channel,
      contactValue: _contact.text.trim(),
      bio: _bio.text.trim(),
    );
    appState.registerOrUpdateProfile(updated);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasNewUser
              ? '¡Bienvenido/a, ${updated.name}! Ya puedes hacer Match.'
              : 'Perfil actualizado',
        ),
      ),
    );
    if (widget.popOnSave && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    }
  }

  void _logout() {
    context.read<AppState>().logout();
    _name.clear();
    _email.clear();
    _career.clear();
    _semester.clear();
    _skills.clear();
    _contact.clear();
    _bio.clear();
    setState(() => _channel = ContactChannel.whatsapp);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión cerrada. Ahora estás como usuario nuevo.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final hasProfile = appState.hasProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(hasProfile ? 'Mi perfil' : 'Crear perfil · Usuario nuevo'),
        actions: [
          if (hasProfile)
            TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Cerrar sesión'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!hasProfile)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person_add_alt_1_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registro rápido de estudiante',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No tienes sesión iniciada. Completa tus datos para postularte con "Me interesa", publicar convocatorias y desbloquear contactos de Match.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    user.initials,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${user.career} · Semestre ${user.semester}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
            ],
            _field(_name, 'Nombre completo',
                validator: _required('Escribe tu nombre')),
            _field(_email, 'Correo universitario (@uniguajira.edu.co)',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Escribe tu correo';
                  if (!v.contains('@')) return 'Correo inválido';
                  return null;
                }),
            _field(_career, 'Carrera / Programa académico',
                helper: 'Ej: Ingeniería de Sistemas, Diseño, Administración',
                validator: _required('Escribe tu carrera')),
            _field(_semester, 'Semestre (1 a 12)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final n = int.tryParse(value?.trim() ?? '');
                  if (n == null || n < 1 || n > 12) return 'Entre 1 y 12';
                  return null;
                }),
            _field(_skills, 'Habilidades / intereses',
                helper: 'Sepáralas con comas. Ej: Flutter, SQL, Diseño',
                validator: _required('Añade al menos una habilidad')),
            const SizedBox(height: 8),
            DropdownButtonFormField<ContactChannel>(
              initialValue: _channel,
              decoration: const InputDecoration(
                labelText: 'Canal de contacto preferido',
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
            _field(_contact, 'Dato de contacto (se revela solo al hacer Match)',
                helper: 'Número de WhatsApp (+57...) o correo',
                validator: _required('Escribe un dato de contacto')),
            _field(_bio, 'Sobre mí (opcional)', maxLines: 3),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: Icon(
                hasProfile ? Icons.save_outlined : Icons.rocket_launch_rounded,
              ),
              label: Text(
                hasProfile
                    ? 'Guardar cambios'
                    : 'Crear mi perfil y empezar a hacer Match',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? Function(String?) _required(String message) {
    return (value) =>
        (value == null || value.trim().isEmpty) ? message : null;
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? helper,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          alignLabelWithHint: maxLines > 1,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
