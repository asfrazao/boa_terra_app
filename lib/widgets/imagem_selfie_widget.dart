import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagemSelfieWidget extends StatelessWidget {
  final void Function(String base64) onImagemSelecionada;
  final VoidCallback onCancelar;

  const ImagemSelfieWidget({
    super.key,
    required this.onImagemSelecionada,
    required this.onCancelar,
  });

  Future<void> _selecionarImagem(ImageSource origem, BuildContext context) async {
    try {
      final picker = ImagePicker();
      final imagem = await picker.pickImage(source: origem);
      if (imagem == null) return;

      final bytes = await imagem.readAsBytes();
      if (bytes.lengthInBytes > 200 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Imagem muito grande (máx: 200KB)')),
        );
        return;
      }

      final base64 = base64Encode(bytes);
      Navigator.pop(context); // fecha o modal
      onImagemSelecionada(base64);
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Deseja tirar uma Selfie ou buscar uma imagem?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Tirar Selfie"),
            onPressed: () => _selecionarImagem(ImageSource.camera, context),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.image),
            label: const Text("Buscar Imagem"),
            onPressed: () => _selecionarImagem(ImageSource.gallery, context),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            icon: const Icon(Icons.cancel),
            label: const Text("Cancelar"),
            onPressed: onCancelar,
          )
        ],
      ),
    );
  }
}
