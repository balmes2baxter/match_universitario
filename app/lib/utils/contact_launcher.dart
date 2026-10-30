import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user_profile.dart';

/// Abre WhatsApp (`https://wa.me/...`) o el cliente de correo (`mailto:...`)
/// directamente en el celular o navegador del estudiante.
Future<void> launchDirectContact(
  BuildContext context,
  UserProfile profile, {
  String? postTitle,
}) async {
  final topic = (postTitle != null && postTitle.trim().isNotEmpty)
      ? ' por la convocatoria "${postTitle.trim()}"'
      : '';
  final message =
      '¡Hola ${profile.name}! Hicimos Match en MatchUni de la Universidad de La Guajira$topic. ¿Coordinamos?';

  Uri targetUri;
  if (profile.contactChannel == ContactChannel.whatsapp) {
    var digits = profile.contactValue.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10 && digits.startsWith('3')) {
      digits = '57$digits';
    }
    if (digits.isEmpty) {
      digits = '573000000000';
    }
    targetUri = Uri.parse(
      'https://wa.me/$digits?text=${Uri.encodeComponent(message)}',
    );
  } else {
    final email = profile.contactValue.trim().isNotEmpty
        ? profile.contactValue.trim()
        : profile.universityEmail.trim();
    final subject = postTitle != null && postTitle.trim().isNotEmpty
        ? 'MatchUni Uniguajira: ${postTitle.trim()}'
        : 'Conexión en MatchUni · Universidad de La Guajira';
    targetUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': message,
      },
    );
  }

  try {
    final launched = await launchUrl(
      targetUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Contacto: ${profile.contactValue} (${profile.contactChannel.label})',
          ),
        ),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Contacto: ${profile.contactValue} (${profile.contactChannel.label})',
          ),
        ),
      );
    }
  }
}
