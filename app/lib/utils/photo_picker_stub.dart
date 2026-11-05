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

Future<Uint8List?> pickProfileImageBytes() async => null;

Future<PickedMediaFile?> pickAllowedImage({bool useCamera = false}) async =>
    null;

Future<PickedMediaFile?> capturePhotoWithCamera() async => null;

Future<PickedMediaFile?> pickStrictPdfFile() async => null;

void openOrDownloadAttachment({
  required String name,
  required String mimeType,
  String? url,
  Uint8List? bytes,
}) {}
