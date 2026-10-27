import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posting.dart';
import '../state/app_state.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetCareerController = TextEditingController();
  final _locationController = TextEditingController();

  PostType _type = PostType.buscaEquipo;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetCareerController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AppState>().addPost(
          type: _type,
          title: _titleController.text,
          description: _descriptionController.text,
          targetCareer:
              _type == PostType.evento ? null : _targetCareerController.text,
          location: _type == PostType.evento ? _locationController.text : null,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Publicación creada')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva publicación')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Tipo de aviso',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 480;
                if (isMobile) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in PostType.values)
                        ChoiceChip(
                          selected: _type == type,
                          avatar: Icon(type.icon, size: 16),
                          label: Text(type.label),
                          onSelected: (selected) {
                            if (selected) setState(() => _type = type);
                          },
                        ),
                    ],
                  );
                }
                return SegmentedButton<PostType>(
                  segments: [
                    for (final type in PostType.values)
                      ButtonSegment<PostType>(
                        value: type,
                        icon: Icon(type.icon),
                        label: Text(type.label),
                      ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) =>
                      setState(() => _type = selection.first),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              _type.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) => (value == null || value.trim().length < 5)
                  ? 'Escribe un título descriptivo'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 6,
              validator: (value) => (value == null || value.trim().length < 10)
                  ? 'Cuéntanos un poco más (mínimo 10 caracteres)'
                  : null,
            ),
            const SizedBox(height: 16),
            if (_type == PostType.evento)
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lugar',
                  border: OutlineInputBorder(),
                ),
              )
            else
              TextFormField(
                controller: _targetCareerController,
                decoration: const InputDecoration(
                  labelText: 'Carrera objetivo (opcional)',
                  helperText: 'Ej: Ingeniería de Sistemas',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.publish),
              label: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
