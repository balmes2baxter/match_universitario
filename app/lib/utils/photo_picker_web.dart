// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

class PickedMediaFile {
  const PickedMediaFile({
    required this.name,
    required this.mimeType,
    required this.bytes,
    required this.isPdf,
    this.error,
  });

  const PickedMediaFile.error(this.error)
      : name = '',
        mimeType = '',
        bytes = const [],
        isPdf = false;

  final String name;
  final String mimeType;
  final List<int> bytes;
  final bool isPdf;
  final String? error;

  Uint8List get uint8Bytes =>
      bytes is Uint8List ? bytes as Uint8List : Uint8List.fromList(bytes);
}

const int _kMaxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

bool _hasPdfSignature(Uint8List data) {
  // Firma mágica de PDF: "%PDF-" (0x25 0x50 0x44 0x46 0x2D)
  if (data.length < 5) return false;
  return data[0] == 0x25 &&
      data[1] == 0x50 &&
      data[2] == 0x44 &&
      data[3] == 0x46 &&
      data[4] == 0x2D;
}

String? _detectValidImageMime(Uint8List data) {
  if (data.length < 12) return null;
  // JPEG: FF D8 FF
  if (data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF) {
    return 'image/jpeg';
  }
  // PNG: 89 50 4E 47 0D 0A 1A 0A
  if (data[0] == 0x89 &&
      data[1] == 0x50 &&
      data[2] == 0x4E &&
      data[3] == 0x47) {
    return 'image/png';
  }
  // WebP: "RIFF"...."WEBP"
  if (data[0] == 0x52 &&
      data[1] == 0x49 &&
      data[2] == 0x46 &&
      data[3] == 0x46 &&
      data[8] == 0x57 &&
      data[9] == 0x45 &&
      data[10] == 0x42 &&
      data[11] == 0x50) {
    return 'image/webp';
  }
  return null;
}

Future<Uint8List?> pickProfileImageBytes() async {
  final picked = await pickAllowedImage(useCamera: false);
  if (picked == null || picked.error != null) return null;
  return picked.uint8Bytes;
}

Future<PickedMediaFile?> pickAllowedImage({bool useCamera = false}) async {
  final completer = Completer<PickedMediaFile?>();
  final input = html.FileUploadInputElement()
    ..accept = 'image/jpeg,image/png,image/webp,.jpg,.jpeg,.png,.webp';
  if (useCamera) {
    input.setAttribute('capture', 'environment');
  }
  input.click();

  input.onChange.listen((_) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    final file = files.first;
    if (file.size > _kMaxFileSizeBytes) {
      if (!completer.isCompleted) {
        completer.complete(
          const PickedMediaFile.error(
            'La imagen supera el límite máximo permitido de 5 MB.',
          ),
        );
      }
      return;
    }

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      Uint8List? bytes;
      if (result is Uint8List) {
        bytes = result;
      } else if (result is ByteBuffer) {
        bytes = result.asUint8List();
      }
      if (bytes == null || bytes.isEmpty) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }
      final validMime = _detectValidImageMime(bytes);
      if (validMime == null) {
        if (!completer.isCompleted) {
          completer.complete(
            const PickedMediaFile.error(
              'Formato no permitido. Solo puedes subir imágenes reales (JPG, PNG o WebP).',
            ),
          );
        }
        return;
      }
      if (!completer.isCompleted) {
        completer.complete(
          PickedMediaFile(
            name: file.name.isNotEmpty ? file.name : 'foto_uniguajira.jpg',
            mimeType: validMime,
            bytes: bytes,
            isPdf: false,
          ),
        );
      }
    });
    reader.onError.listen((_) {
      if (!completer.isCompleted) completer.complete(null);
    });
  });

  return completer.future;
}

/// Abre la cámara en vivo (Webcam en PC o cámara trasera/frontal en celular)
/// y si el dispositivo no tiene permiso de getUserMedia, usa el selector nativo con `capture="environment"`.
Future<PickedMediaFile?> capturePhotoWithCamera() async {
  final mediaDevices = html.window.navigator.mediaDevices;
  if (mediaDevices == null) {
    return pickAllowedImage(useCamera: true);
  }

  html.MediaStream? stream;
  try {
    stream = await mediaDevices.getUserMedia({
      'video': {'facingMode': 'environment'},
      'audio': false,
    });
  } catch (_) {
    try {
      stream = await mediaDevices.getUserMedia({'video': true, 'audio': false});
    } catch (_) {
      return pickAllowedImage(useCamera: true);
    }
  }

  final completer = Completer<PickedMediaFile?>();
  final activeStream = stream;

  final overlay = html.DivElement()
    ..style.cssText =
        'position:fixed;inset:0;background:rgba(28,20,13,0.82);z-index:2147483646;display:flex;align-items:center;justify-content:center;padding:16px;font-family:sans-serif;';

  final card = html.DivElement()
    ..style.cssText =
        'background:#FAF6F0;border-radius:20px;max-width:480px;width:100%;padding:18px;box-shadow:0 20px 50px rgba(0,0,0,0.4);display:flex;flex-direction:column;gap:12px;border:1px solid #E6DCD2;';

  final title = html.DivElement()
    ..style.cssText =
        'font-size:16px;font-weight:800;color:#1C140D;display:flex;justify-content:space-between;align-items:center;'
    ..text = '📷 Tomar Foto · Match Universitario';

  final video = html.VideoElement()
    ..autoplay = true
    ..muted = true
    ..setAttribute('playsinline', 'true')
    ..style.cssText =
        'width:100%;max-height:340px;background:#000;border-radius:14px;object-fit:cover;'
    ..srcObject = activeStream;

  final btnRow = html.DivElement()
    ..style.cssText = 'display:flex;gap:10px;justify-content:flex-end;';

  final cancelBtn = html.ButtonElement()
    ..text = 'Cancelar'
    ..style.cssText =
        'padding:10px 16px;border-radius:12px;border:1px solid #C8B9A6;background:#FFFFFF;color:#1C140D;font-weight:700;cursor:pointer;';

  final snapBtn = html.ButtonElement()
    ..text = '📸 Capturar foto'
    ..style.cssText =
        'padding:10px 18px;border-radius:12px;border:none;background:#EA6A00;color:#FFFFFF;font-weight:800;cursor:pointer;';

  void cleanup() {
    try {
      activeStream.getTracks().forEach((t) => t.stop());
    } catch (_) {}
    overlay.remove();
  }

  cancelBtn.onClick.listen((_) {
    cleanup();
    if (!completer.isCompleted) completer.complete(null);
  });

  snapBtn.onClick.listen((_) {
    final w = video.videoWidth > 0 ? video.videoWidth : 640;
    final h = video.videoHeight > 0 ? video.videoHeight : 480;
    final canvas = html.CanvasElement(width: w, height: h);
    canvas.context2D.drawImage(video, 0, 0);
    final dataUrl = canvas.toDataUrl('image/jpeg', 0.88);
    cleanup();
    final commaIdx = dataUrl.indexOf(',');
    if (commaIdx != -1) {
      final b64 = dataUrl.substring(commaIdx + 1);
      final bytes = base64Decode(b64);
      final ts = DateTime.now().millisecondsSinceEpoch;
      if (!completer.isCompleted) {
        completer.complete(
          PickedMediaFile(
            name: 'Foto_Camara_$ts.jpg',
            mimeType: 'image/jpeg',
            bytes: bytes,
            isPdf: false,
          ),
        );
      }
    } else {
      if (!completer.isCompleted) completer.complete(null);
    }
  });

  btnRow.append(cancelBtn);
  btnRow.append(snapBtn);
  card.append(title);
  card.append(video);
  card.append(btnRow);
  overlay.append(card);
  html.document.body?.append(overlay);

  return completer.future;
}

Future<PickedMediaFile?> pickStrictPdfFile() async {
  final completer = Completer<PickedMediaFile?>();
  final input = html.FileUploadInputElement()..accept = 'application/pdf,.pdf';
  input.click();

  input.onChange.listen((_) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    final file = files.first;
    final lowerName = file.name.trim().toLowerCase();
    if (!lowerName.endsWith('.pdf')) {
      if (!completer.isCompleted) {
        completer.complete(
          const PickedMediaFile.error(
            'Archivo bloqueado: Por seguridad solo se permiten documentos en formato .PDF.',
          ),
        );
      }
      return;
    }
    if (file.size > _kMaxFileSizeBytes) {
      if (!completer.isCompleted) {
        completer.complete(
          const PickedMediaFile.error(
            'El documento PDF supera el límite máximo de 5 MB.',
          ),
        );
      }
      return;
    }

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      Uint8List? bytes;
      if (result is Uint8List) {
        bytes = result;
      } else if (result is ByteBuffer) {
        bytes = result.asUint8List();
      }
      if (bytes == null || bytes.isEmpty) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }
      if (!_hasPdfSignature(bytes)) {
        if (!completer.isCompleted) {
          completer.complete(
            const PickedMediaFile.error(
              'Archivo rechazado por seguridad: El archivo no es un PDF auténtico (%PDF).',
            ),
          );
        }
        return;
      }
      if (!completer.isCompleted) {
        completer.complete(
          PickedMediaFile(
            name: file.name,
            mimeType: 'application/pdf',
            bytes: bytes,
            isPdf: true,
          ),
        );
      }
    });
    reader.onError.listen((_) {
      if (!completer.isCompleted) completer.complete(null);
    });
  });

  return completer.future;
}

void openOrDownloadAttachment({
  required String name,
  required String mimeType,
  String? url,
  Uint8List? bytes,
}) {
  if (url != null && url.trim().isNotEmpty) {
    html.window.open(url.trim(), '_blank');
    return;
  }
  if (bytes != null && bytes.isNotEmpty) {
    final blob = html.Blob([bytes], mimeType);
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(blobUrl, '_blank');
    return;
  }
  // Si es un PDF semilla de demostración sin binario adjunto, generamos un PDF válido al vuelo
  if (mimeType == 'application/pdf') {
    final demoPdf = _generateValidDemoPdfBytes(name);
    final blob = html.Blob([demoPdf], 'application/pdf');
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(blobUrl, '_blank');
  }
}

Uint8List _generateValidDemoPdfBytes(String title) {
  final safeTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9_.\- ]'), ' ');
  final content = '''%PDF-1.4
1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj
2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj
3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >> endobj
4 0 obj << /Length 168 >> stream
BT
/F1 16 Tf
50 720 Td
(Universidad de La Guajira - Match Universitario) Tj
/F1 12 Tf
0 -30 Td
(Documento academico verificado: $safeTitle) Tj
ET
endstream endobj
5 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj
xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000229 00000 n 
0000000449 00000 n 
trailer << /Size 6 /Root 1 0 R >>
startxref
517
%%EOF''';
  return Uint8List.fromList(content.codeUnits);
}
