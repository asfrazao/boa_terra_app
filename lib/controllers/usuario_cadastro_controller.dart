// lib/controllers/usuario_cadastro_controller.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/compact_image_helper.dart';
import '../utils/validador_convite.dart';

abstract class UsuarioCadastroController extends ChangeNotifier {
  // Variáveis comuns
  final parte1 = TextEditingController();
  final parte2 = TextEditingController();
  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final rgController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final repetirSenhaController = TextEditingController();

  final foco1 = FocusNode();
  final foco2 = FocusNode();

  bool salvando = false;
  bool carregandoImagem = false;

  String? imagemBase64;
  String? conviteAtual;
  String? igrejaSelecionada;
  List<Map<String, dynamic>> igrejas = [];

  int etapaAtual = 0;

  String get conviteFormatado =>
      'BOATERRA-${parte1.text.toUpperCase()}-${parte2.text.toUpperCase()}';

  /// 🧠 Após build
  void inicializarCampos() {
    WidgetsBinding.instance.addPostFrameCallback((_) => foco1.requestFocus());
  }

  /// 📸 Imagem
  Future<void> tirarSelfie() async {
    carregandoImagem = true;
    notifyListeners();
    imagemBase64 = await CompactImageHelper.selecionarDaCamera();
    carregandoImagem = false;
    notifyListeners();
  }

  Future<void> carregarFotoGaleria() async {
    carregandoImagem = true;
    notifyListeners();
    imagemBase64 = await CompactImageHelper.selecionarDaGaleria();
    carregandoImagem = false;
    notifyListeners();
  }

  /// 🔑 Convite e Igreja
  Future<bool> validarConvite(BuildContext context) async {
    final convite = conviteFormatado;

    if (!ValidadorConvite.validar(convite)) {
      mostrarSnack(context, '❌ Convite inválido');
      return false;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('igrejas')
        .where('convite', isEqualTo: convite)
        .get();

    if (snapshot.docs.isEmpty) {
      mostrarSnack(context, '⚠️ Convite não encontrado');
      return false;
    }

    igrejas = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'nome': data['denominacao'] ?? 'Sem nome',
        'admin_setor': data['admin_setor'] ?? '',
      };
    }).toList();

    conviteAtual = convite;
    etapaAtual = 1;
    notifyListeners();
    return true;
  }

  void mostrarSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// 🚨 Método abstrato que será implementado nos filhos
  Future<void> salvar(BuildContext context);
}
