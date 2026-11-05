import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

enum PostType { buscaEquipo, grupoEstudio, evento }

extension PostTypeX on PostType {
  String get label {
    switch (this) {
      case PostType.buscaEquipo:
        return 'Busco Equipo';
      case PostType.grupoEstudio:
        return 'Grupo de Estudio';
      case PostType.evento:
        return 'Evento';
    }
  }

  String get emoji {
    switch (this) {
      case PostType.buscaEquipo:
        return '🛠️';
      case PostType.grupoEstudio:
        return '📚';
      case PostType.evento:
        return '📅';
    }
  }

  IconData get icon {
    switch (this) {
      case PostType.buscaEquipo:
        return Icons.handyman_outlined;
      case PostType.grupoEstudio:
        return Icons.menu_book_outlined;
      case PostType.evento:
        return Icons.event_outlined;
    }
  }

  String get description {
    switch (this) {
      case PostType.buscaEquipo:
        return 'Recluta compañeros para un proyecto o trabajo final.';
      case PostType.grupoEstudio:
        return 'Arma un grupo para preparar parciales.';
      case PostType.evento:
        return 'Comparte una actividad del campus.';
    }
  }
}

enum AttachmentKind { image, pdf }

/// Archivo adjunto seguro para convocatorias y Matches (solo Imágenes y PDF).
class MatchAttachment {
  const MatchAttachment({
    required this.id,
    required this.name,
    required this.kind,
    required this.mimeType,
    required this.sizeBytes,
    required this.uploaderId,
    required this.uploaderName,
    required this.createdAt,
    this.url,
    this.dataBase64,
  });

  final String id;
  final String name;
  final AttachmentKind kind;
  final String mimeType;
  final int sizeBytes;
  final String uploaderId;
  final String uploaderName;
  final DateTime createdAt;
  final String? url;
  final String? dataBase64;

  bool get isPdf => kind == AttachmentKind.pdf;
  bool get isImage => kind == AttachmentKind.image;

  Uint8List? get bytes {
    final raw = dataBase64;
    if (raw == null || raw.isEmpty) return null;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    final kb = sizeBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'uploaderId': uploaderId,
        'uploaderName': uploaderName,
        'createdAt': createdAt.toUtc().toIso8601String(),
        if (url != null && url!.isNotEmpty) 'url': url,
        if (dataBase64 != null && dataBase64!.isNotEmpty)
          'dataBase64': dataBase64,
      };

  factory MatchAttachment.fromJson(Map<String, dynamic> json) {
    final rawKind = (json['kind'] ?? 'pdf').toString().toLowerCase();
    final kind =
        rawKind == 'image' ? AttachmentKind.image : AttachmentKind.pdf;
    final rawDate = (json['createdAt'] ?? json['created_at'])?.toString() ?? '';
    return MatchAttachment(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Archivo').toString(),
      kind: kind,
      mimeType: (json['mimeType'] ??
              json['mime_type'] ??
              (kind == AttachmentKind.pdf ? 'application/pdf' : 'image/jpeg'))
          .toString(),
      sizeBytes: (json['sizeBytes'] ?? json['size_bytes'] as num?)?.toInt() ?? 0,
      uploaderId:
          (json['uploaderId'] ?? json['uploader_id'] ?? '').toString(),
      uploaderName:
          (json['uploaderName'] ?? json['uploader_name'] ?? 'Estudiante')
              .toString(),
      createdAt: DateTime.tryParse(rawDate)?.toLocal() ?? DateTime.now(),
      url: json['url'] as String?,
      dataBase64: (json['dataBase64'] ?? json['data_base64']) as String?,
    );
  }
}

class Posting {
  const Posting({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorCareer,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.targetCareer,
    this.location,
    this.applicantIds = const [],
    this.acceptedIds = const [],
    this.attachments = const [],
  });

  final String id;
  final String authorId;
  final String authorName;
  final String authorCareer;
  final PostType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? targetCareer;
  final String? location;

  /// Estudiantes que marcaron "Me interesa".
  final List<String> applicantIds;

  /// Estudiantes que el autor ya aceptó (contacto revelado).
  final List<String> acceptedIds;

  /// Archivos e imágenes adjuntas en la convocatoria o en el Match (solo Imágenes y PDF).
  final List<MatchAttachment> attachments;

  int get applicantCount => applicantIds.length;
  int get acceptedCount => acceptedIds.length;

  Posting copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorCareer,
    PostType? type,
    String? title,
    String? description,
    DateTime? createdAt,
    String? targetCareer,
    String? location,
    List<String>? applicantIds,
    List<String>? acceptedIds,
    List<MatchAttachment>? attachments,
  }) {
    return Posting(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorCareer: authorCareer ?? this.authorCareer,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      targetCareer: targetCareer ?? this.targetCareer,
      location: location ?? this.location,
      applicantIds: applicantIds ?? this.applicantIds,
      acceptedIds: acceptedIds ?? this.acceptedIds,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'authorName': authorName,
        'authorCareer': authorCareer,
        'type': type.name,
        'title': title,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'targetCareer': targetCareer,
        'location': location,
        'applicantIds': applicantIds,
        'acceptedIds': acceptedIds,
        'attachments': attachments.map((a) => a.toJson()).toList(),
      };

  /// Serialización snake_case para la tabla `public.postings` en Supabase / PostgreSQL.
  Map<String, dynamic> toSupabaseRow() => {
        'id': id,
        'author_id': authorId,
        'author_name': authorName,
        'author_career': authorCareer,
        'type': type.name,
        'title': title,
        'description': description,
        'target_career': targetCareer,
        'location': location,
        'applicant_ids': applicantIds,
        'accepted_ids': acceptedIds,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  /// Deserializa tanto desde JSON camelCase (local) como desde filas snake_case (Supabase).
  factory Posting.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? PostType.buscaEquipo.name).toString();
    final parsedType = PostType.values.firstWhere(
      (t) => t.name == rawType,
      orElse: () => PostType.buscaEquipo,
    );

    final rawCreatedAt =
        (json['created_at'] ?? json['createdAt'])?.toString() ?? '';
    final parsedCreatedAt =
        DateTime.tryParse(rawCreatedAt)?.toLocal() ?? DateTime.now();

    final rawAttachments = json['attachments'];
    final parsedAttachments = <MatchAttachment>[];
    if (rawAttachments is List) {
      for (final item in rawAttachments) {
        if (item is Map<String, dynamic>) {
          parsedAttachments.add(MatchAttachment.fromJson(item));
        } else if (item is Map) {
          parsedAttachments.add(
            MatchAttachment.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return Posting(
      id: (json['id'] ?? '').toString(),
      authorId: (json['author_id'] ?? json['authorId'] ?? '').toString(),
      authorName: (json['author_name'] ?? json['authorName'] ?? '').toString(),
      authorCareer:
          (json['author_career'] ?? json['authorCareer'] ?? '').toString(),
      type: parsedType,
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: parsedCreatedAt,
      targetCareer:
          (json['target_career'] ?? json['targetCareer']) as String?,
      location: json['location'] as String?,
      applicantIds: ((json['applicant_ids'] ?? json['applicantIds'])
                  as List<dynamic>? ??
              const [])
          .map((e) => e.toString())
          .toList(),
      acceptedIds: ((json['accepted_ids'] ?? json['acceptedIds'])
                  as List<dynamic>? ??
              const [])
          .map((e) => e.toString())
          .toList(),
      attachments: parsedAttachments,
    );
  }
}
