import 'dart:typed_data';

enum ContactChannel { whatsapp, email }

extension ContactChannelX on ContactChannel {
  String get label {
    switch (this) {
      case ContactChannel.whatsapp:
        return 'WhatsApp';
      case ContactChannel.email:
        return 'Correo institucional';
    }
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.universityEmail,
    required this.career,
    required this.semester,
    required this.skills,
    required this.contactChannel,
    required this.contactValue,
    this.bio = '',
    this.headline = '',
    this.faculty = 'Facultad de Ingeniería',
    this.campus = 'Sede Riohacha',
    this.availability = 'Disponible para Proyectos y Estudio',
    this.diplomas = const [],
    this.projects = const [],
    this.languages = const ['Español'],
    this.portfolioUrl = '',
    this.avatarUrl,
    this.photoBytes,
    this.bannerPreset = 0,
  });

  final String id;
  final String name;
  final String universityEmail;
  final String career;
  final int semester;
  final List<String> skills;
  final ContactChannel contactChannel;
  final String contactValue;
  final String bio;

  // Nuevos campos enriquecidos del perfil universitario
  final String headline;
  final String faculty;
  final String campus;
  final String availability;
  final List<String> diplomas;
  final List<String> projects;
  final List<String> languages;
  final String portfolioUrl;
  final String? avatarUrl;
  final Uint8List? photoBytes;
  final int bannerPreset;

  bool get hasCustomPhoto =>
      (photoBytes != null && photoBytes!.isNotEmpty) ||
      (avatarUrl != null && avatarUrl!.trim().isNotEmpty);

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Porcentaje de completitud del perfil (0.0 a 1.0)
  double get completeness {
    if (name.trim().isEmpty) return 0.1;
    var points = 0;
    const total = 8;
    if (name.trim().isNotEmpty && career.trim().isNotEmpty) points++;
    if (universityEmail.trim().isNotEmpty) points++;
    if (contactValue.trim().isNotEmpty) points++;
    if (skills.isNotEmpty) points++;
    if (bio.trim().isNotEmpty || headline.trim().isNotEmpty) points++;
    if (diplomas.isNotEmpty) points++;
    if (projects.isNotEmpty || portfolioUrl.trim().isNotEmpty) points++;
    if (hasCustomPhoto) points++;
    return (points / total).clamp(0.0, 1.0);
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? universityEmail,
    String? career,
    int? semester,
    List<String>? skills,
    ContactChannel? contactChannel,
    String? contactValue,
    String? bio,
    String? headline,
    String? faculty,
    String? campus,
    String? availability,
    List<String>? diplomas,
    List<String>? projects,
    List<String>? languages,
    String? portfolioUrl,
    String? avatarUrl,
    Uint8List? photoBytes,
    bool clearPhoto = false,
    int? bannerPreset,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      universityEmail: universityEmail ?? this.universityEmail,
      career: career ?? this.career,
      semester: semester ?? this.semester,
      skills: skills ?? this.skills,
      contactChannel: contactChannel ?? this.contactChannel,
      contactValue: contactValue ?? this.contactValue,
      bio: bio ?? this.bio,
      headline: headline ?? this.headline,
      faculty: faculty ?? this.faculty,
      campus: campus ?? this.campus,
      availability: availability ?? this.availability,
      diplomas: diplomas ?? this.diplomas,
      projects: projects ?? this.projects,
      languages: languages ?? this.languages,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      avatarUrl: clearPhoto ? null : (avatarUrl ?? this.avatarUrl),
      photoBytes: clearPhoto ? null : (photoBytes ?? this.photoBytes),
      bannerPreset: bannerPreset ?? this.bannerPreset,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'universityEmail': universityEmail,
        'career': career,
        'semester': semester,
        'skills': skills,
        'contactChannel': contactChannel.name,
        'contactValue': contactValue,
        'bio': bio,
        'headline': headline,
        'faculty': faculty,
        'campus': campus,
        'availability': availability,
        'diplomas': diplomas,
        'projects': projects,
        'languages': languages,
        'portfolioUrl': portfolioUrl,
        'avatarUrl': avatarUrl,
        'bannerPreset': bannerPreset,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      universityEmail: json['universityEmail'] as String,
      career: json['career'] as String,
      semester: json['semester'] as int,
      skills: (json['skills'] as List<dynamic>).cast<String>(),
      contactChannel: ContactChannel.values
          .firstWhere((c) => c.name == json['contactChannel']),
      contactValue: json['contactValue'] as String,
      bio: (json['bio'] as String?) ?? '',
      headline: (json['headline'] as String?) ?? '',
      faculty: (json['faculty'] as String?) ?? 'Facultad de Ingeniería',
      campus: (json['campus'] as String?) ?? 'Sede Riohacha',
      availability:
          (json['availability'] as String?) ?? 'Disponible para Proyectos',
      diplomas: (json['diplomas'] as List<dynamic>?)?.cast<String>() ?? const [],
      projects: (json['projects'] as List<dynamic>?)?.cast<String>() ?? const [],
      languages:
          (json['languages'] as List<dynamic>?)?.cast<String>() ?? const ['Español'],
      portfolioUrl: (json['portfolioUrl'] as String?) ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      bannerPreset: (json['bannerPreset'] as int?) ?? 0,
    );
  }
}
