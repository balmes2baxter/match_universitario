import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/environment.dart';
import '../data/mock_data.dart';
import '../models/posting.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

/// Estado global de Match Universitario (Uniguajira).
/// - Persiste automáticamente el perfil del estudiante, las publicaciones y los
///   matches en el dispositivo (`SharedPreferences` / `localStorage`).
/// - Se sincroniza en tiempo real con **Supabase PostgreSQL** cuando está
///   configurado (por variables de entorno, parámetros URL o desde el panel de nube).
class AppState extends ChangeNotifier {
  AppState({bool? enableMocks, SupabaseService? supabaseService})
      : _isMockEnabled = enableMocks ?? Environment.isMockEnabled {
    _currentUser = kDemoCurrentUser;
    if (_isMockEnabled) {
      _posts.addAll(buildMockPostings());
    }
    _rebuildDirectory();
    _supabase = supabaseService ?? SupabaseService();
    _initPersistenceAndCloud();
  }

  static const String _kCurrentUserKey = 'matchuni_current_user_v1';
  static const String _kSavedPostsKey = 'matchuni_saved_posts_v1';
  static const String _kSavedProfilesKey = 'matchuni_saved_profiles_v1';
  static const String _kSupabaseUrlKey = 'matchuni_supabase_url_v1';
  static const String _kSupabaseAnonKey = 'matchuni_supabase_anon_v1';

  final bool _isMockEnabled;
  bool get isMockEnabled => _isMockEnabled;

  late SupabaseService _supabase;
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  bool get isCloudConnected => _supabase.isEnabled;
  String _cloudUrl = Environment.supabaseUrl;
  String _cloudAnonKey = Environment.supabaseAnonKey;
  String get cloudUrl => _cloudUrl;
  Timer? _pollingTimer;

  late UserProfile _currentUser;
  final List<Posting> _posts = [];
  final Map<String, UserProfile> _directory = {};

  UserProfile get currentUser => _currentUser;
  bool get hasProfile => _currentUser.name.trim().isNotEmpty;

  List<Posting> get feed {
    final sorted = [..._posts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  /// Publicaciones creadas por el usuario actual.
  List<Posting> get myPostings =>
      feed.where((p) => p.authorId == _currentUser.id).toList();

  /// Publicaciones a las que el usuario actual aplicó.
  List<Posting> get myApplications =>
      feed.where((p) => p.applicantIds.contains(_currentUser.id)).toList();

  /// Postulaciones enviadas por el usuario actual que aún están pendientes.
  List<Posting> get pendingApplications => myApplications
      .where((p) => !p.acceptedIds.contains(_currentUser.id))
      .toList();

  /// Solicitudes recibidas ("Me interesa") en mis publicaciones.
  int get incomingInterestCount => myPostings.fold(
        0,
        (sum, p) => sum + p.applicantCount - p.acceptedCount,
      );

  /// Coincidencias confirmadas donde me aceptaron y debo ver el contacto.
  List<Posting> get confirmedMatches => myApplications
      .where((p) => p.acceptedIds.contains(_currentUser.id))
      .toList();

  /// Mis propias convocatorias donde ya acepté al menos a un estudiante (Match mutuo).
  List<Posting> get myPostingsWithAcceptedMatches =>
      myPostings.where((p) => p.acceptedCount > 0).toList();

  /// Todos los Matches confirmados de mi cuenta (donde me aceptaron o donde yo acepté).
  List<Posting> get allMutualMatches {
    final byId = <String, Posting>{};
    for (final p in confirmedMatches) {
      byId[p.id] = p;
    }
    for (final p in myPostingsWithAcceptedMatches) {
      byId[p.id] = p;
    }
    final list = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Calcula el porcentaje de afinidad (68% - 98%) entre el usuario actual y un Match.
  int affinityScoreFor(Posting post) {
    int score = 70;
    final myCareer = _currentUser.career.trim().toLowerCase();
    final target = (post.targetCareer ?? '').trim().toLowerCase();
    final authorCareer = post.authorCareer.trim().toLowerCase();

    if (myCareer.isNotEmpty) {
      if (target.isNotEmpty && target == myCareer) {
        score += 15;
      } else if (authorCareer == myCareer) {
        score += 11;
      } else if (target.isEmpty) {
        score += 6;
      }
    } else {
      score += 8;
    }

    final textBlob = '${post.title} ${post.description}'.toLowerCase();
    for (final skill in _currentUser.skills) {
      final clean = skill.trim().toLowerCase();
      if (clean.length >= 3 && textBlob.contains(clean)) {
        score += 5;
      }
    }
    for (final dip in _currentUser.diplomas) {
      final clean = dip.trim().toLowerCase();
      if (clean.length >= 4 && textBlob.contains(clean)) {
        score += 4;
      }
    }
    if (post.attachments.isNotEmpty) {
      score += 4;
    }
    return score.clamp(68, 98);
  }

  /// Explica brevemente por qué este Match le puede interesar al estudiante actual.
  String affinityReasonFor(Posting post) {
    final myCareer = _currentUser.career.trim();
    if (hasProfile && myCareer.isNotEmpty) {
      if (post.targetCareer != null &&
          post.targetCareer!.toLowerCase() == myCareer.toLowerCase()) {
        return 'Busca tu carrera ($myCareer)';
      }
      if (post.authorCareer.toLowerCase() == myCareer.toLowerCase()) {
        return 'De tu misma carrera ($myCareer)';
      }
      final textBlob = '${post.title} ${post.description}'.toLowerCase();
      for (final skill in _currentUser.skills) {
        if (skill.trim().length >= 3 &&
            textBlob.contains(skill.trim().toLowerCase())) {
          return 'Conecta con tu habilidad: $skill';
        }
      }
    }
    if (post.targetCareer != null && post.targetCareer!.trim().isNotEmpty) {
      return 'Ideal para ${post.targetCareer}';
    }
    return 'Abierto a todas las carreras · Uniguajira';
  }

  /// Matches recomendados que le pueden interesar al usuario actual (excluye propios y ya likeados).
  List<Posting> get recommendedPostings {
    final candidates = feed
        .where((p) => !isOwner(p) && !hasApplied(p))
        .toList();
    candidates.sort((a, b) {
      final cmp = affinityScoreFor(b).compareTo(affinityScoreFor(a));
      if (cmp != 0) return cmp;
      return b.createdAt.compareTo(a.createdAt);
    });
    return candidates.take(6).toList();
  }

  /// Calcula la afinidad con otro estudiante del directorio para sugerir conexiones.
  int peerAffinityScore(UserProfile peer) {
    int score = 72;
    if (hasProfile) {
      if (peer.career.toLowerCase() == _currentUser.career.toLowerCase()) {
        score += 14;
      } else if (peer.faculty.toLowerCase() ==
          _currentUser.faculty.toLowerCase()) {
        score += 8;
      }
      if ((peer.semester - _currentUser.semester).abs() <= 2) {
        score += 5;
      }
      final mySkills =
          _currentUser.skills.map((s) => s.toLowerCase().trim()).toSet();
      for (final s in peer.skills) {
        if (mySkills.contains(s.toLowerCase().trim())) {
          score += 5;
        }
      }
    } else {
      score += (peer.skills.length * 2).clamp(2, 12);
    }
    return score.clamp(72, 98);
  }

  /// Estudiantes recomendados con los que el usuario puede conectar según su perfil.
  List<UserProfile> get recommendedPeers {
    final peers = _directory.values
        .where((u) => u.id != _currentUser.id && u.name.trim().isNotEmpty)
        .toList();
    peers.sort((a, b) => peerAffinityScore(b).compareTo(peerAffinityScore(a)));
    return peers.take(6).toList();
  }

  /// Matches ya existentes entre estudiantes de la plataforma.
  List<Posting> get campusMatches =>
      feed.where((p) => p.acceptedCount > 0).toList();

  Future<void> _initPersistenceAndCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Verificar si vienen credenciales de Supabase por URL (?supa_url=...&supa_key=...)
      //    o si se solicitó modo de pruebas estrictamente local (?local_only=1)
      final queryParams = Uri.base.queryParameters;
      final isLocalOnly = queryParams['local_only'] == '1' ||
          queryParams['local_only'] == 'true';
      final urlParam = queryParams['supa_url']?.trim();
      final keyParam = queryParams['supa_key']?.trim();
      if (isLocalOnly) {
        _cloudUrl = '';
        _cloudAnonKey = '';
        _supabase = SupabaseService(baseUrl: '', anonKey: '');
      } else if (urlParam != null &&
          urlParam.isNotEmpty &&
          keyParam != null &&
          keyParam.isNotEmpty) {
        _cloudUrl = urlParam;
        _cloudAnonKey = keyParam;
        await prefs.setString(_kSupabaseUrlKey, _cloudUrl);
        await prefs.setString(_kSupabaseAnonKey, _cloudAnonKey);
      } else if (_cloudUrl.isEmpty || _cloudAnonKey.isEmpty) {
        _cloudUrl = prefs.getString(_kSupabaseUrlKey) ?? '';
        _cloudAnonKey = prefs.getString(_kSupabaseAnonKey) ?? '';
      }

      if (!isLocalOnly && _cloudUrl.isNotEmpty && _cloudAnonKey.isNotEmpty) {
        _supabase = SupabaseService(
          baseUrl: _cloudUrl,
          anonKey: _cloudAnonKey,
        );
      }

      // 2. Restaurar perfiles guardados localmente
      final rawProfiles = prefs.getString(_kSavedProfilesKey);
      if (rawProfiles != null && rawProfiles.isNotEmpty) {
        final decoded = jsonDecode(rawProfiles) as List<dynamic>;
        for (final item in decoded.whereType<Map<String, dynamic>>()) {
          final profile = UserProfile.fromJson(item);
          if (profile.id.isNotEmpty) {
            _directory[profile.id] = profile;
          }
        }
      }

      // 3. Restaurar sesión del estudiante en este teléfono
      final rawUser = prefs.getString(_kCurrentUserKey);
      if (rawUser != null && rawUser.isNotEmpty) {
        final restored =
            UserProfile.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
        if (restored.name.trim().isNotEmpty) {
          _currentUser = restored;
          _directory[_currentUser.id] = _currentUser;
        }
      }

      // 4. Restaurar publicaciones guardadas localmente
      final rawPosts = prefs.getString(_kSavedPostsKey);
      if (rawPosts != null && rawPosts.isNotEmpty) {
        final decoded = jsonDecode(rawPosts) as List<dynamic>;
        final restoredPosts = decoded
            .whereType<Map<String, dynamic>>()
            .map(Posting.fromJson)
            .toList();
        if (restoredPosts.isNotEmpty) {
          _mergePostings(restoredPosts);
        }
      }

      notifyListeners();

      // 5. Si Supabase está activo, sincronizar datos desde la nube
      if (_supabase.isEnabled) {
        await refreshFromCloud();
      }
      _startPeriodicSync();
    } catch (_) {
      // En entornos de test sin SharedPreferences continuamos en memoria.
    }
  }

  void _mergePostings(List<Posting> incoming) {
    final byId = <String, Posting>{
      for (final p in _posts) p.id: p,
    };
    for (final p in incoming) {
      byId[p.id] = p;
    }
    _posts
      ..clear()
      ..addAll(byId.values);
  }

  Future<void> _saveLocalSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (hasProfile) {
        await prefs.setString(
          _kCurrentUserKey,
          jsonEncode(_currentUser.toJson()),
        );
      } else {
        await prefs.remove(_kCurrentUserKey);
      }
      await prefs.setString(
        _kSavedPostsKey,
        jsonEncode(_posts.map((p) => p.toJson()).toList()),
      );
      await prefs.setString(
        _kSavedProfilesKey,
        jsonEncode(_directory.values.map((u) => u.toJson()).toList()),
      );
    } catch (_) {
      // Ignorar fallos de almacenamiento en entorno de pruebas.
    }
  }

  /// Configura y conecta Supabase en caliente desde la interfaz.
  Future<bool> configureSupabase({
    required String url,
    required String anonKey,
  }) async {
    _cloudUrl = url.trim();
    _cloudAnonKey = anonKey.trim();
    _supabase = SupabaseService(baseUrl: _cloudUrl, anonKey: _cloudAnonKey);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSupabaseUrlKey, _cloudUrl);
      await prefs.setString(_kSupabaseAnonKey, _cloudAnonKey);
    } catch (_) {}

    if (!_supabase.isEnabled) {
      notifyListeners();
      return false;
    }

    final ok = await refreshFromCloud();
    _startPeriodicSync();
    if (ok && hasProfile) {
      _safeCloudOp(() => _supabase.upsertProfile(_currentUser));
    }
    return ok;
  }

  void _safeCloudOp(Future<void> Function() op) {
    if (!_supabase.isEnabled) return;
    unawaited(() async {
      try {
        await op();
      } catch (_) {
        // Ignorar errores de red en modo offline o durante tests unitarios.
      }
    }());
  }

  void _startPeriodicSync() {
    _pollingTimer?.cancel();
    if (!_supabase.isEnabled) return;
    // Sincronización inteligente periódica cada 45 segundos para mantener
    // el tablero actualizado en vivo sin colapsar la conexión ni la batería.
    _pollingTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (_supabase.isEnabled && !_isSyncing) {
        refreshFromCloud(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  /// Sincroniza perfiles y convocatorias desde Supabase PostgreSQL.
  Future<bool> refreshFromCloud({bool silent = false}) async {
    if (!_supabase.isEnabled) return false;
    _isSyncing = true;
    if (!silent) {
      notifyListeners();
    }
    try {
      final cloudProfiles = await _supabase.fetchProfiles();
      for (final profile in cloudProfiles) {
        _directory[profile.id] = profile;
        if (hasProfile && profile.id == _currentUser.id) {
          _currentUser = profile;
        }
      }

      final cloudPosts = await _supabase.fetchPostings();
      if (cloudPosts.isNotEmpty) {
        _mergePostings(cloudPosts);
      } else if (_posts.isNotEmpty) {
        // Si la tabla en Supabase está recién creada y vacía, subimos la semilla inicial
        for (final u in _directory.values) {
          _safeCloudOp(() => _supabase.upsertProfile(u));
        }
        for (final p in _posts) {
          _safeCloudOp(() => _supabase.upsertPosting(p));
        }
      }

      await _saveLocalSnapshot();
      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  void _rebuildDirectory() {
    if (_isMockEnabled) {
      for (final u in kMockDirectory) {
        _directory.putIfAbsent(u.id, () => u);
      }
    }
    if (hasProfile) {
      _directory[_currentUser.id] = _currentUser;
    }
  }

  UserProfile? profileById(String id) {
    if (id == _currentUser.id) return hasProfile ? _currentUser : null;
    return _directory[id];
  }

  /// Permite recuperar/iniciar sesión buscando el correo institucional o personal.
  Future<UserProfile?> loginByEmail(String email) async {
    final clean = email.trim().toLowerCase();
    if (clean.isEmpty) return null;

    if (_supabase.isEnabled) {
      try {
        final remote = await _supabase.findProfileByEmail(clean);
        if (remote != null) {
          _currentUser = remote;
          _directory[remote.id] = remote;
          await _saveLocalSnapshot();
          notifyListeners();
          return remote;
        }
      } catch (_) {}
    }

    for (final profile in _directory.values) {
      if (profile.universityEmail.trim().toLowerCase() == clean) {
        _currentUser = profile;
        await _saveLocalSnapshot();
        notifyListeners();
        return profile;
      }
    }
    return null;
  }

  void registerOrUpdateProfile(UserProfile profile) {
    final assignedId = (profile.id.isEmpty || profile.id == 'me')
        ? 'u_${DateTime.now().millisecondsSinceEpoch}'
        : profile.id;
    final previousId = _currentUser.id;
    final updatedProfile = profile.copyWith(id: assignedId);

    _currentUser = updatedProfile;
    _posts.asMap().forEach((index, post) {
      var changed = false;
      var updatedPost = post;
      if (post.authorId == previousId || post.authorId == assignedId) {
        updatedPost = updatedPost.copyWith(
          authorId: assignedId,
          authorName: updatedProfile.name,
          authorCareer: updatedProfile.career,
        );
        changed = true;
      }
      if (previousId != assignedId &&
          (post.applicantIds.contains(previousId) ||
              post.acceptedIds.contains(previousId))) {
        final newApplicants = post.applicantIds
            .map((id) => id == previousId ? assignedId : id)
            .toSet()
            .toList();
        final newAccepted = post.acceptedIds
            .map((id) => id == previousId ? assignedId : id)
            .toSet()
            .toList();
        updatedPost = updatedPost.copyWith(
          applicantIds: newApplicants,
          acceptedIds: newAccepted,
        );
        changed = true;
      }
      if (changed) {
        _posts[index] = updatedPost;
        _safeCloudOp(() => _supabase.upsertPosting(updatedPost));
      }
    });
    _rebuildDirectory();
    unawaited(_saveLocalSnapshot());
    _safeCloudOp(() => _supabase.upsertProfile(updatedProfile));
    notifyListeners();
  }

  /// Cierra la sesión actual en el dispositivo manteniendo las publicaciones del campus.
  void logout() {
    _currentUser = kDemoCurrentUser;
    unawaited(_saveLocalSnapshot());
    notifyListeners();
  }

  Posting addPost({
    required PostType type,
    required String title,
    required String description,
    String? targetCareer,
    String? location,
    List<MatchAttachment> attachments = const [],
  }) {
    final authorName =
        hasProfile ? _currentUser.name : 'Estudiante Uniguajira';
    final authorCareer = hasProfile ? _currentUser.career : 'Uniguajira';
    final initialApplicants = (_isMockEnabled && type != PostType.evento)
        ? const <String>['u1']
        : const <String>[];
    final post = Posting(
      id: 'p${DateTime.now().microsecondsSinceEpoch}',
      authorId: _currentUser.id,
      authorName: authorName,
      authorCareer: authorCareer,
      type: type,
      title: title.trim(),
      description: description.trim(),
      targetCareer: (targetCareer?.trim().isEmpty ?? true)
          ? null
          : targetCareer!.trim(),
      location:
          (location?.trim().isEmpty ?? true) ? null : location!.trim(),
      createdAt: DateTime.now(),
      applicantIds: initialApplicants,
      attachments: attachments,
    );
    _posts.insert(0, post);
    unawaited(_saveLocalSnapshot());
    _safeCloudOp(() => _supabase.upsertPosting(post));
    notifyListeners();
    return post;
  }

  /// Adjunta una Imagen, Foto de cámara o PDF verificado a una convocatoria / Match
  /// y la sincroniza en Supabase Storage + `public.postings`.
  Future<MatchAttachment> addAttachmentToPost({
    required Posting post,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
    required bool isPdf,
  }) async {
    String? uploadedUrl;
    if (_supabase.isEnabled) {
      uploadedUrl = await _supabase.uploadAttachmentToStorage(
        postingId: post.id,
        fileName: fileName,
        mimeType: mimeType,
        bytes: bytes,
      );
    }

    final uploaderName =
        hasProfile ? _currentUser.name : 'Estudiante Uniguajira';
    final attachment = MatchAttachment(
      id: 'att_${DateTime.now().microsecondsSinceEpoch}',
      name: fileName,
      kind: isPdf ? AttachmentKind.pdf : AttachmentKind.image,
      mimeType: mimeType,
      sizeBytes: bytes.length,
      uploaderId: _currentUser.id,
      uploaderName: uploaderName,
      createdAt: DateTime.now(),
      url: uploadedUrl,
      // Si no hay URL pública o la imagen es pequeña (<700 KB), guardamos también base64 para vista rápida
      dataBase64: (uploadedUrl == null || (!isPdf && bytes.length <= 700 * 1024))
          ? base64Encode(bytes)
          : null,
    );

    final current = _posts.firstWhere(
      (p) => p.id == post.id,
      orElse: () => post,
    );
    final updated = current.copyWith(
      attachments: [...current.attachments, attachment],
    );
    _replace(current, updated);
    unawaited(_saveLocalSnapshot());
    _safeCloudOp(() => _supabase.upsertPosting(updated));
    notifyListeners();
    return attachment;
  }

  void removeAttachmentFromPost(Posting post, String attachmentId) {
    final current = _posts.firstWhere(
      (p) => p.id == post.id,
      orElse: () => post,
    );
    final updated = current.copyWith(
      attachments:
          current.attachments.where((a) => a.id != attachmentId).toList(),
    );
    _replace(current, updated);
    unawaited(_saveLocalSnapshot());
    _safeCloudOp(() => _supabase.upsertPosting(updated));
    notifyListeners();
  }

  void deletePost(Posting post) {
    if (!isOwner(post)) return;
    _posts.removeWhere((p) => p.id == post.id);
    unawaited(_saveLocalSnapshot());
    _safeCloudOp(() => _supabase.deletePosting(post.id));
    notifyListeners();
  }

  bool hasApplied(Posting post) =>
      post.applicantIds.contains(_currentUser.id);

  bool isOwner(Posting post) => post.authorId == _currentUser.id;

  void applyToPost(Posting post) {
    if (isOwner(post) || hasApplied(post)) return;
    final updated = post.copyWith(
      applicantIds: [...post.applicantIds, _currentUser.id],
    );
    _replace(post, updated);
    unawaited(_saveLocalSnapshot());
    _safeCloudOp(() => _supabase.upsertPosting(updated));
    notifyListeners();
  }

  /// Permite retirar el Like ("Me interesa") de una publicación.
  void withdrawApplication(Posting post) {
    if (!hasApplied(post)) return;
    final updated = post.copyWith(
      applicantIds:
          post.applicantIds.where((id) => id != _currentUser.id).toList(),
      acceptedIds:
          post.acceptedIds.where((id) => id != _currentUser.id).toList(),
    );
    _replace(post, updated);
    unawaited(_saveLocalSnapshot());
    _safeCloudOp(() => _supabase.upsertPosting(updated));
    notifyListeners();
  }

  void acceptApplicant(Posting post, String applicantId) {
    if (!isOwner(post) || post.acceptedIds.contains(applicantId)) return;
    final updated = post.copyWith(
      acceptedIds: [...post.acceptedIds, applicantId],
    );
    _replace(post, updated);
    unawaited(_saveLocalSnapshot());
    _safeCloudOp(() => _supabase.upsertPosting(updated));
    notifyListeners();
  }

  /// Permite en la demo simular que el autor de una publicación acepta el Match
  /// del usuario actual, desbloqueando el WhatsApp o correo al instante.
  void simulateAuthorAcceptsMe(Posting post) {
    if (!hasApplied(post) || post.acceptedIds.contains(_currentUser.id)) return;
    final updated = post.copyWith(
      acceptedIds: [...post.acceptedIds, _currentUser.id],
    );
    _replace(post, updated);
    unawaited(_saveLocalSnapshot());
    _safeCloudOp(() => _supabase.upsertPosting(updated));
    notifyListeners();
  }

  List<UserProfile> applicantsFor(Posting post) => post.applicantIds
      .map(profileById)
      .whereType<UserProfile>()
      .toList();

  List<UserProfile> acceptedContactsFor(Posting post) => post.acceptedIds
      .map(profileById)
      .whereType<UserProfile>()
      .toList();

  void _replace(Posting original, Posting updated) {
    final index = _posts.indexWhere((p) => p.id == original.id);
    if (index != -1) _posts[index] = updated;
  }
}
