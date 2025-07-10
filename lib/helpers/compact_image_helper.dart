import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class CompactImageHelper {
  static const int maxSizeKB = 200;

  /// Seleciona imagem da câmera, redimensiona se necessário e retorna base64
  static Future<String?> selecionarDaCamera() async {
    return _processarImagem(ImageSource.camera);
  }

  /// Seleciona imagem da galeria, redimensiona se necessário e retorna base64
  static Future<String?> selecionarDaGaleria() async {
    return _processarImagem(ImageSource.gallery);
  }

  /// Função base para captura ou seleção de imagem e compactação
  static Future<String?> _processarImagem(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final imagem = await picker.pickImage(source: source, imageQuality: 100);
      if (imagem == null) return null;

      final bytes = await imagem.readAsBytes();

      if (bytes.lengthInBytes <= maxSizeKB * 1024) {
        return base64Encode(bytes);
      }

      final reduzido = await compute(_reduzirImagem, bytes);
      return reduzido != null ? base64Encode(reduzido) : null;
    } catch (e) {
      debugPrint('Erro ao processar imagem: $e');
      return null;
    }
  }

  /// Reduz o tamanho da imagem até que fique abaixo de 200KB
  static Uint8List? _reduzirImagem(Uint8List originalBytes) {
    try {
      final decodedImage = img.decodeImage(originalBytes);
      if (decodedImage == null) return null;

      img.Image imagem = decodedImage;
      int qualidade = 90;
      Uint8List encoded;

      do {
        final redimensionada = img.copyResize(
          imagem,
          width: (imagem.width * 0.9).round(),
        );
        encoded = Uint8List.fromList(img.encodeJpg(redimensionada, quality: qualidade));
        qualidade -= 5;
        imagem = redimensionada;
      } while (encoded.lengthInBytes > maxSizeKB * 1024 && qualidade > 10);

      return encoded;
    } catch (e) {
      debugPrint('Erro ao redimensionar imagem: $e');
      return null;
    }
  }
}
