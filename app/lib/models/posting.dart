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
    );
  }
}
