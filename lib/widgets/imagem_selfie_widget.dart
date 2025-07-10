import 'package:flutter/material.dart';
import '../helpers/compact_image_helper.dart';

class ImagemSelfieWidget extends StatelessWidget {
  final void Function(String base64) onImagemSelecionada;
  final VoidCallback onCancelar;

  const ImagemSelfieWidget({
    super.key,
    required this.onImagemSelecionada,
    required this.onCancelar,
  });

  Future<void> _selecionarDaCamera(BuildContext context) async {
    Navigator.pop(context);
    final base64 = await CompactImageHelper.selecionarDaCamera();
    if (base64 != null) {
      onImagemSelecionada(base64);
    } else {
      _mostrarErro(context);
    }
  }

  Future<void> _selecionarDaGaleria(BuildContext context) async {
    Navigator.pop(context);
    final base64 = await CompactImageHelper.selecionarDaGaleria();
    if (base64 != null) {
      onImagemSelecionada(base64);
    } else {
      _mostrarErro(context);
    }
  }

  void _mostrarErro(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ Não foi possível processar a imagem')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Escolha uma imagem:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _selecionarDaCamera(context),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Tirar Selfie'),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _selecionarDaGaleria(context),
          icon: const Icon(Icons.photo),
          label: const Text('Buscar Imagem'),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: onCancelar,
          icon: const Icon(Icons.cancel),
          label: const Text('Cancelar'),
        ),
      ],
    );
  }
}
