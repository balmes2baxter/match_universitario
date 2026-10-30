import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

/// Modal para recuperar un perfil existente ingresando el correo universitario.
Future<void> showLoginByEmailDialog(BuildContext context) async {
  final emailCtrl = TextEditingController();
  var isLoading = false;
  String? errorText;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.login_rounded, color: Color(0xFFEA6A00)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Recuperar mi perfil',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingresa el correo institucional o personal con el que creaste tu perfil en MatchUni:',
                  style: TextStyle(fontSize: 13.5, height: 1.35),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo (@uniguajira.edu.co)',
                    hintText: 'ej. tu.nombre@uniguajira.edu.co',
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                    errorText: errorText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: isLoading
                    ? null
                    : () async {
                        final email = emailCtrl.text.trim();
                        if (email.isEmpty) {
                          setState(() => errorText = 'Ingresa tu correo');
                          return;
                        }
                        setState(() {
                          isLoading = true;
                          errorText = null;
                        });
                        final found = await context
                            .read<AppState>()
                            .loginByEmail(email);
                        if (!ctx.mounted) return;
                        if (found != null) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '¡Bienvenido de nuevo, ${found.name}!',
                              ),
                            ),
                          );
                        } else {
                          setState(() {
                            isLoading = false;
                            errorText =
                                'No encontramos ese correo. Crea tu perfil primero.';
                          });
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEA6A00),
                  foregroundColor: Colors.white,
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Entrar'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Modal para instalar la PWA en el celular y configurar/verificar Supabase.
Future<void> showPwaAndCloudModal(BuildContext context) async {
  final appState = context.read<AppState>();
  final urlCtrl = TextEditingController(text: appState.cloudUrl);
  final keyCtrl = TextEditingController();
  var isConnecting = false;
  String? statusMsg;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final state = ctx.watch<AppState>();
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0DB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.install_mobile_rounded,
                          color: Color(0xFFEA6A00),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instalar App en tu Celular (PWA) y Nube',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1C140D),
                              ),
                            ),
                            Text(
                              'Úsala como aplicación nativa en Android y iPhone',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF6E5D4F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. INSTRUCCIONES PWA
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE6D8C9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📲 Cómo descargarla en el teléfono:',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF1C140D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• En Android (Chrome): toca los 3 puntos (⋮) arriba a la derecha y selecciona "Instalar aplicación" o "Agregar a pantalla principal".\n'
                          '• En iPhone (Safari): toca el botón Compartir (⬆️) abajo y selecciona "Agregar a inicio".',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A3B31),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                const ClipboardData(
                                  text:
                                      'https://balmes2baxter.github.io/match_universitario/',
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '¡Enlace copiado! Compártelo por WhatsApp.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.share_rounded, size: 17),
                            label: const Text(
                              'Copiar link de la App para compartir',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. CONEXIÓN SUPABASE (BASE DE DATOS EN LA NUBE)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE6D8C9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              state.isCloudConnected
                                  ? Icons.cloud_done_rounded
                                  : Icons.cloud_queue_rounded,
                              color: state.isCloudConnected
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFEA6A00),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.isCloudConnected
                                    ? 'Base de Datos Supabase Conectada'
                                    : 'Conectar Base de Datos Supabase (PostgreSQL)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: Color(0xFF1C140D),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tus datos ya se guardan automáticamente en este teléfono. Pega aquí tu Project URL y Anon Key de Supabase para sincronizar entre todos los dispositivos:',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF6E5D4F),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: urlCtrl,
                          decoration: InputDecoration(
                            labelText: 'Supabase Project URL',
                            hintText: 'https://xxxx.supabase.co',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: keyCtrl,
                          decoration: InputDecoration(
                            labelText: 'Supabase Anon Public Key',
                            hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        if (statusMsg != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            statusMsg!,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: statusMsg!.startsWith('✅')
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: isConnecting
                                ? null
                                : () async {
                                    setState(() {
                                      isConnecting = true;
                                      statusMsg = null;
                                    });
                                    final ok = await state.configureSupabase(
                                      url: urlCtrl.text,
                                      anonKey: keyCtrl.text,
                                    );
                                    if (!ctx.mounted) return;
                                    setState(() {
                                      isConnecting = false;
                                      statusMsg = ok
                                          ? '✅ ¡Conectado y sincronizado con Supabase!'
                                          : '⚠️ Verifica la URL, la Anon Key y que hayas corrido init_uniguajira.sql.';
                                    });
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFEA6A00),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.sync_rounded, size: 18),
                            label: Text(
                              isConnecting
                                  ? 'Conectando...'
                                  : 'Conectar y Sincronizar Nube',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
