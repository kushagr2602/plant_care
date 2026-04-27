import 'dart:convert';
import 'dart:typed_data';

class ImageUtils {
  ImageUtils._();

  static String toBase64(Uint8List bytes) => base64Encode(bytes);

  static String toDataUrl(Uint8List bytes, {String mimeType = 'image/jpeg'}) {
    return 'data:$mimeType;base64,${toBase64(bytes)}';
  }
}
