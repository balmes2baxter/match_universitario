import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../state/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
    final user = context.read<AppState>().currentUser;
    _name = TextEditingController(text: user.name);
    _email = TextEditingController(text: user.universityEmail);
    _career = TextEditingController(text: user.career);
    _semester = TextEditingController(text: user.semester.toString());
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
    final current = context.read<AppState>().currentUser;
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
    context.read<AppState>().registerOrUpdateProfile(updated);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil guardado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AppState>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
            _field(_name, 'Nombre completo',
                validator: _required('Escribe tu nombre')),
            _field(_email, 'Correo universitario',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Escribe tu correo';
                  if (!v.contains('@')) return 'Correo inválido';
                  return null;
                }),
            _field(_career, 'Carrera',
                validator: _required('Escribe tu carrera')),
            _field(_semester, 'Semestre',
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
            _field(_contact, 'Dato de contacto',
                helper: 'Número de WhatsApp o correo',
                validator: _required('Escribe un dato de contacto')),
            _field(_bio, 'Sobre mí (opcional)', maxLines: 3),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar cambios'),
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
