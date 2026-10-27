import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/posting.dart';
import '../models/user_profile.dart';

/// Estado global del MVP con datos en memoria.
/// Arranca sin sesión iniciada (usuario nuevo) pero con convocatorias y matches
/// activos en el campus para explorar y probar el flujo completo.
class AppState extends ChangeNotifier {
  AppState() {
    _currentUser = kDemoCurrentUser;
    _posts.addAll(buildMockPostings());
    _rebuildDirectory();
  }

  late UserProfile _currentUser;
  final List<Posting> _posts = [];
  final Map<String, UserProfile> _directory = {};

  UserProfile get currentUser => _currentUser;
  bool get hasProfile => _currentUser.name.trim().isNotEmpty;

  List<Posting> get feed {
    final sorted = [..._posts]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
  int get incomingInterestCount => myPostings
      .fold(0, (sum, p) => sum + p.applicantCount - p.acceptedCount);

  /// Coincidencias confirmadas donde me aceptaron y debo ver el contacto.
  List<Posting> get confirmedMatches => myApplications
      .where((p) => p.acceptedIds.contains(_currentUser.id))
      .toList();

  /// Matches ya existentes entre estudiantes de la plataforma.
  List<Posting> get campusMatches =>
      feed.where((p) => p.acceptedCount > 0).toList();

  void _rebuildDirectory() {
    _directory.clear();
    if (hasProfile) {
      _directory[_currentUser.id] = _currentUser;
    }
    for (final u in kMockDirectory) {
      _directory[u.id] = u;
    }
  }

  UserProfile? profileById(String id) {
    if (id == _currentUser.id) return hasProfile ? _currentUser : null;
    return _directory[id];
  }

  void registerOrUpdateProfile(UserProfile profile) {
    _currentUser = profile;
    _posts.asMap().forEach((index, post) {
      if (post.authorId == profile.id) {
        _posts[index] = post.copyWith(
          authorName: profile.name,
          authorCareer: profile.career,
        );
      }
    });
    _rebuildDirectory();
    notifyListeners();
  }

  /// Cierra la sesión actual para volver a probar como visitante / usuario nuevo.
  void logout() {
    _currentUser = kDemoCurrentUser;
    _rebuildDirectory();
    notifyListeners();
  }

  Posting addPost({
    required PostType type,
    required String title,
    required String description,
    String? targetCareer,
    String? location,
  }) {
    final authorName = hasProfile ? _currentUser.name : 'Estudiante Uniguajira';
    final authorCareer = hasProfile ? _currentUser.career : 'Uniguajira';
    // En modo demo, pre-asignamos 1 estudiante interesado para que el usuario
    // nuevo pueda probar de inmediato el botón "Aceptar" en sus avisos.
    final initialApplicants =
        type == PostType.evento ? const <String>[] : const <String>['u1'];
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
      location: (location?.trim().isEmpty ?? true) ? null : location!.trim(),
      createdAt: DateTime.now(),
      applicantIds: initialApplicants,
    );
    _posts.add(post);
    notifyListeners();
    return post;
  }

  bool hasApplied(Posting post) =>
      post.applicantIds.contains(_currentUser.id);

  bool isOwner(Posting post) => post.authorId == _currentUser.id;

  void applyToPost(Posting post) {
    if (isOwner(post) || hasApplied(post)) return;
    _replace(
      post,
      post.copyWith(applicantIds: [...post.applicantIds, _currentUser.id]),
    );
    notifyListeners();
  }

  void acceptApplicant(Posting post, String applicantId) {
    if (!isOwner(post) || post.acceptedIds.contains(applicantId)) return;
    _replace(
      post,
      post.copyWith(acceptedIds: [...post.acceptedIds, applicantId]),
    );
    notifyListeners();
  }

  /// Permite en la demo simular que el autor de una publicación acepta el Match
  /// del usuario actual, desbloqueando el WhatsApp o correo al instante.
  void simulateAuthorAcceptsMe(Posting post) {
    if (!hasApplied(post) || post.acceptedIds.contains(_currentUser.id)) return;
    _replace(
      post,
      post.copyWith(acceptedIds: [...post.acceptedIds, _currentUser.id]),
    );
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
