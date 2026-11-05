import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posting.dart';
import '../state/app_state.dart';
import '../utils/photo_picker.dart';

/// Panel profesional de evidencias y archivos compartidos dentro de un Match o Convocatoria.
/// Permite:
/// 1. Tomar foto en vivo con la cámara (`📷 Tomar foto`)
/// 2. Subir imagen verificada (`🖼️ Subir imagen`: JPG, PNG, WebP)
/// 3. Subir documento PDF verificado (`📄 Subir PDF`: estrictamente `.pdf` con firma `%PDF-`)
class MatchAttachmentsPanel extends StatefulWidget {
  const MatchAttachmentsPanel({
    super.key,
    required this.posting,
    this.compact = false,
    this.allowUpload = true,
  });

  final Posting posting;
  final bool compact;
  final bool allowUpload;

  @override
  State<MatchAttachmentsPanel> createState() => _MatchAttachmentsPanelState();
}

class _MatchAttachmentsPanelState extends State<MatchAttachmentsPanel> {
  bool _isUploading = false;

  Future<void> _handlePickedFile(PickedMediaFile? picked) async {
    if (picked == null || !mounted) return;
    if (picked.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(picked.error!)),
            ],
          ),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final appState = context.read<AppState>();
      await appState.addAttachmentToPost(
        post: widget.posting,
        fileName: picked.name,
        mimeType: picked.mimeType,
        bytes: picked.uint8Bytes,
        isPdf: picked.isPdf,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            picked.isPdf
                ? '📄 Documento PDF "${picked.name}" guardado en el Match.'
                : '🖼️ Imagen "${picked.name}" guardada en el Match.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _onTakePhoto() async {
    final picked = await capturePhotoWithCamera();
    await _handlePickedFile(picked);
  }

  Future<void> _onUploadImage() async {
    final picked = await pickAllowedImage(useCamera: false);
    await _handlePickedFile(picked);
  }

  Future<void> _onUploadPdf() async {
    final picked = await pickStrictPdfFile();
    await _handlePickedFile(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final attachments = widget.posting.attachments;

    if (widget.compact && attachments.isEmpty && !widget.allowUpload) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(widget.compact ? 10 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.compact
                      ? 'Archivos adjuntos (${attachments.length})'
                      : 'Evidencias y Documentos del Match (${attachments.length})',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Solo Imagen / PDF',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            // Si hay imágenes adjuntas, mostrar vista previa visual destacada en la tarjeta
            for (final imgAtt in attachments.where((a) => !a.isPdf).take(1)) ...[
              _FeaturedAttachmentBanner(attachment: imgAtt),
              const SizedBox(height: 8),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final att in attachments)
                  _AttachmentTile(
                    attachment: att,
                    canDelete: widget.allowUpload &&
                        context.read<AppState>().currentUser.id ==
                            att.uploaderId,
                    onDelete: () => context
                        .read<AppState>()
                        .removeAttachmentFromPost(widget.posting, att.id),
                  ),
              ],
            ),
          ] else if (!widget.compact) ...[
            const SizedBox(height: 4),
            Text(
              'Comparte fotos de avances, apuntes o documentos PDF del proyecto.',
              style: TextStyle(
                fontSize: 11.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (widget.allowUpload) ...[
            const SizedBox(height: 10),
            if (_isUploading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Subiendo y verificando archivo en Supabase...',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _ActionUploadChip(
                    icon: Icons.camera_alt_outlined,
                    label: 'Tomar foto',
                    color: const Color(0xFFEA6A00),
                    onTap: _onTakePhoto,
                  ),
                  _ActionUploadChip(
                    icon: Icons.image_outlined,
                    label: 'Subir imagen',
                    color: const Color(0xFF0284C7),
                    onTap: _onUploadImage,
                  ),
                  _ActionUploadChip(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'Subir PDF',
                    color: const Color(0xFFDC2626),
                    onTap: _onUploadPdf,
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

class _ActionUploadChip extends StatelessWidget {
  const _ActionUploadChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedAttachmentBanner extends StatelessWidget {
  const _FeaturedAttachmentBanner({required this.attachment});

  final MatchAttachment attachment;

  Widget _buildBannerImage() {
    final bytes = attachment.bytes;
    final url = attachment.url ?? '';
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }
    if (url.contains('Clases_de_Arte_Uniguajira.jpg')) {
      return Image.asset(
        'assets/images/clases_de_arte.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.network(url, fit: BoxFit.cover),
      );
    }
    if (url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.asset(
          'assets/images/clases_de_arte.jpg',
          fit: BoxFit.cover,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680, maxHeight: 640),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.image_rounded,
                          color: Color(0xFFEA6A00),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            attachment.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: _buildBannerImage(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Subido por ${attachment.uploaderName} · ${attachment.formattedSize}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 195,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBannerImage(),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.zoom_out_map_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Ampliar imagen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.attachment,
    required this.canDelete,
    required this.onDelete,
  });

  final MatchAttachment attachment;
  final bool canDelete;
  final VoidCallback onDelete;

  void _openAttachment(BuildContext context) {
    if (attachment.isPdf) {
      openOrDownloadAttachment(
        name: attachment.name,
        mimeType: attachment.mimeType,
        url: attachment.url,
        bytes: attachment.bytes,
      );
      return;
    }

    // Mostrar visor de imagen en pantalla completa
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final bytes = attachment.bytes;
        final url = attachment.url;
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 620),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.image_rounded, color: Color(0xFFEA6A00)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          attachment.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: bytes != null
                          ? Image.memory(bytes, fit: BoxFit.contain)
                          : (url != null && url.isNotEmpty)
                              ? Image.network(url, fit: BoxFit.contain)
                              : const SizedBox(
                                  height: 180,
                                  child: Center(
                                    child: Icon(Icons.broken_image_outlined,
                                        size: 48),
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Subido por ${attachment.uploaderName} · ${attachment.formattedSize}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPdf = attachment.isPdf;
    final bytes = attachment.bytes;
    final url = attachment.url;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openAttachment(context),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPdf
                ? const Color(0xFFDC2626).withValues(alpha: 0.35)
                : scheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPdf && (bytes != null || (url != null && url.isNotEmpty)))
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: bytes != null
                      ? Image.memory(bytes, fit: BoxFit.cover)
                      : Image.network(
                          url!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                ),
              )
            else
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPdf
                      ? const Color(0xFFDC2626).withValues(alpha: 0.12)
                      : const Color(0xFF0284C7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPdf
                      ? Icons.picture_as_pdf_rounded
                      : Icons.image_outlined,
                  size: 20,
                  color:
                      isPdf ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                ),
              ),
            const SizedBox(width: 9),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    attachment.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C140D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${isPdf ? "PDF" : "Imagen"} · ${attachment.formattedSize} · ${attachment.uploaderName}',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.open_in_new_rounded,
              size: 15,
              color: isPdf ? const Color(0xFFDC2626) : scheme.primary,
            ),
            if (canDelete) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: onDelete,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: scheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Selector de adjuntos para usar dentro del formulario de Nueva Publicación (`CreatePostScreen`).
class DraftAttachmentsEditor extends StatelessWidget {
  const DraftAttachmentsEditor({
    super.key,
    required this.attachments,
    required this.onAdd,
    required this.onRemove,
  });

  final List<MatchAttachment> attachments;
  final void Function(PickedMediaFile file) onAdd;
  final void Function(String id) onRemove;

  Future<void> _pick(
    BuildContext context,
    Future<PickedMediaFile?> Function() loader,
  ) async {
    final res = await loader();
    if (res == null || !context.mounted) return;
    if (res.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(res.error!),
        ),
      );
      return;
    }
    onAdd(res);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Adjuntar Foto, Imagen o Documento PDF (Opcional)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Por seguridad solo se permiten imágenes (JPG, PNG, WebP) y documentos .PDF.',
            style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionUploadChip(
                icon: Icons.camera_alt_outlined,
                label: 'Tomar foto',
                color: const Color(0xFFEA6A00),
                onTap: () => _pick(context, capturePhotoWithCamera),
              ),
              _ActionUploadChip(
                icon: Icons.image_outlined,
                label: 'Subir imagen',
                color: const Color(0xFF0284C7),
                onTap: () =>
                    _pick(context, () => pickAllowedImage(useCamera: false)),
              ),
              _ActionUploadChip(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Subir PDF',
                color: const Color(0xFFDC2626),
                onTap: () => _pick(context, pickStrictPdfFile),
              ),
            ],
          ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final att in attachments)
                  _AttachmentTile(
                    attachment: att,
                    canDelete: true,
                    onDelete: () => onRemove(att.id),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
