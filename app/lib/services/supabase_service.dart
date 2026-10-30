import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/environment.dart';
import '../models/posting.dart';
import '../models/user_profile.dart';

/// Servicio REST ligero para sincronizar perfiles y convocatorias con Supabase
/// (PostgREST API sobre PostgreSQL).
class SupabaseService {
  SupabaseService({
    String? baseUrl,
    String? anonKey,
    http.Client? client,
  })  : _baseUrl = (baseUrl ?? Environment.supabaseUrl).trim().replaceAll(RegExp(r'/$'), ''),
        _anonKey = (anonKey ?? Environment.supabaseAnonKey).trim(),
        _client = client ?? http.Client();

  final String _baseUrl;
  final String _anonKey;
  final http.Client _client;

  bool get isEnabled => _baseUrl.isNotEmpty && _anonKey.isNotEmpty;

  Map<String, String> get _headers => {
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
        'Content-Type': 'application/json',
      };

  /// Obtiene todos los perfiles registrados en `public.profiles`.
  Future<List<UserProfile>> fetchProfiles() async {
    if (!isEnabled) return const [];
    final uri = Uri.parse('$_baseUrl/rest/v1/profiles?select=*');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error al cargar perfiles (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(UserProfile.fromJson)
        .toList();
  }

  /// Busca un perfil por correo institucional o personal (case-insensitive).
  Future<UserProfile?> findProfileByEmail(String email) async {
    if (!isEnabled || email.trim().isEmpty) return null;
    final cleanEmail = Uri.encodeQueryComponent(email.trim().toLowerCase());
    final uri = Uri.parse(
      '$_baseUrl/rest/v1/profiles?university_email=ilike.$cleanEmail&limit=1',
    );
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }
    final decoded = jsonDecode(response.body) as List<dynamic>;
    if (decoded.isEmpty) return null;
    return UserProfile.fromJson(decoded.first as Map<String, dynamic>);
  }

  /// Crea o actualiza un perfil (`UPSERT` por `id`) en `public.profiles`.
  Future<void> upsertProfile(UserProfile profile) async {
    if (!isEnabled) return;
    final uri = Uri.parse('$_baseUrl/rest/v1/profiles?on_conflict=id');
    final response = await _client.post(
      uri,
      headers: {
        ..._headers,
        'Prefer': 'resolution=merge-duplicates,return=minimal',
      },
      body: jsonEncode(profile.toSupabaseRow()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error al guardar perfil (${response.statusCode})');
    }
  }

  /// Obtiene todas las convocatorias ordenadas de más reciente a más antigua.
  Future<List<Posting>> fetchPostings() async {
    if (!isEnabled) return const [];
    final uri = Uri.parse(
      '$_baseUrl/rest/v1/postings?select=*&order=created_at.desc',
    );
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error al cargar convocatorias (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Posting.fromJson)
        .toList();
  }

  /// Crea o actualiza una convocatoria (`UPSERT` por `id`) en `public.postings`.
  Future<void> upsertPosting(Posting posting) async {
    if (!isEnabled) return;
    final uri = Uri.parse('$_baseUrl/rest/v1/postings?on_conflict=id');
    final response = await _client.post(
      uri,
      headers: {
        ..._headers,
        'Prefer': 'resolution=merge-duplicates,return=minimal',
      },
      body: jsonEncode(posting.toSupabaseRow()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error al guardar convocatoria (${response.statusCode})');
    }
  }

  /// Elimina una convocatoria por su `id`.
  Future<void> deletePosting(String postId) async {
    if (!isEnabled) return;
    final cleanId = Uri.encodeQueryComponent(postId);
    final uri = Uri.parse('$_baseUrl/rest/v1/postings?id=eq.$cleanId');
    await _client.delete(uri, headers: _headers);
  }
}
