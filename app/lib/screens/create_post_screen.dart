import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posting.dart';
import '../state/app_state.dart';
import '../utils/photo_picker.dart';
import '../widgets/match_attachments_panel.dart';

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
  final List<_DraftMediaItem> _draftAttachments = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetCareerController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _addDraftFile(PickedMediaFile file) {
    final appState = context.read<AppState>();
    final uploaderName =
        appState.hasProfile ? appState.currentUser.name : 'Estudiante Uniguajira';
    final attachment = MatchAttachment(
      id: 'att_${DateTime.now().microsecondsSinceEpoch}',
      name: file.name,
      kind: file.isPdf ? AttachmentKind.pdf : AttachmentKind.image,
      mimeType: file.mimeType,
      sizeBytes: file.uint8Bytes.length,
      uploaderId: appState.currentUser.id,
      uploaderName: uploaderName,
      createdAt: DateTime.now(),
      dataBase64: base64Encode(file.uint8Bytes),
    );
    setState(() {
      _draftAttachments.add(_DraftMediaItem(attachment: attachment, raw: file));
    });
  }

  void _removeDraftFile(String id) {
    setState(() {
      _draftAttachments.removeWhere((item) => item.attachment.id == id);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    final appState = context.read<AppState>();
    final created = appState.addPost(
      type: _type,
      title: _titleController.text,
      description: _descriptionController.text,
      targetCareer:
          _type == PostType.evento ? null : _targetCareerController.text,
      location: _type == PostType.evento ? _locationController.text : null,
    );

    for (final item in _draftAttachments) {
      await appState.addAttachmentToPost(
        post: created,
        fileName: item.raw.name,
        mimeType: item.raw.mimeType,
        bytes: item.raw.uint8Bytes,
        isPdf: item.raw.isPdf,
      );
    }

    if (!mounted) return;
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
            const SizedBox(height: 16),
            DraftAttachmentsEditor(
              attachments:
                  _draftAttachments.map((e) => e.attachment).toList(),
              onAdd: _addDraftFile,
              onRemove: _removeDraftFile,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.publish),
              label: Text(_isSubmitting ? 'Publicando...' : 'Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftMediaItem {
  const _DraftMediaItem({
    required this.attachment,
    required this.raw,
  });

  final MatchAttachment attachment;
  final PickedMediaFile raw;
}
