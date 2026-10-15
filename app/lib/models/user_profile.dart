enum ContactChannel { whatsapp, email }

extension ContactChannelX on ContactChannel {
  String get label {
    switch (this) {
      case ContactChannel.whatsapp:
        return 'WhatsApp';
      case ContactChannel.email:
        return 'Correo';
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

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
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
    );
  }
}
