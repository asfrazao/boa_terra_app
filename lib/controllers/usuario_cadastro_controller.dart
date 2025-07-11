import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/compact_image_helper.dart';
import '../utils/validador_convite.dart';

abstract class UsuarioCadastroController extends ChangeNotifier {
  /// 🔑 Código do convite dividido
  final parte1 = TextEditingController();
  final parte2 = TextEditingController();

  /// 🔧 Estado de navegação
  int etapaAtual = 0;
  bool salvando = false;
  bool carregandoImagem = false;

  /// 📸 Imagem capturada (base64)
  String? imagemBase64;

  /// 🎫 Dados de convite e igreja
  String? conviteAtual;
  String? igrejaSelecionada;
  List<Map<String, dynamic>> igrejas = [];

  /// ⚠️ Controladores legados (mover para controllers filhos no futuro)
  /// Ainda presentes para compatibilidade com Membro/Pastor atuais
  @Deprecated('Use campos específicos em controllers filhos')
  final nomeController = TextEditingController();

  @Deprecated('Use campos específicos em controllers filhos')
  final sobrenomeController = TextEditingController();

  @Deprecated('Use campos específicos em controllers filhos')
  final rgController = TextEditingController();

  @Deprecated('Use campos específicos em controllers filhos')
  final emailController = TextEditingController();

  @Deprecated('Use campos específicos em controllers filhos')
  final senhaController = TextEditingController();

  @Deprecated('Use campos específicos em controllers filhos')
  final repetirSenhaController = TextEditingController();

  /// 🔎 Foco nos campos de convite
  final foco1 = FocusNode();
  final foco2 = FocusNode();

  String get conviteFormatado =>
      'BOATERRA-${parte1.text.toUpperCase()}-${parte2.text.toUpperCase()}';

  /// 🧠 Após o build inicial, foca no campo convite
  void inicializarCampos() {
    WidgetsBinding.instance.addPostFrameCallback((_) => foco1.requestFocus());
  }

  /// 📸 Tira selfie com compactação
  Future<void> tirarSelfie() async {
    carregandoImagem = true;
    notifyListeners();
    imagemBase64 = await CompactImageHelper.selecionarDaCamera();
    carregandoImagem = false;
    notifyListeners();
  }

  /// 🖼️ Seleciona foto da galeria
  Future<void> carregarFotoGaleria() async {
    carregandoImagem = true;
    notifyListeners();
    imagemBase64 = await CompactImageHelper.selecionarDaGaleria();
    carregandoImagem = false;
    notifyListeners();
  }

  /// 🔐 Valida o convite informado e carrega as igrejas compatíveis
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

  /// 🚨 Método abstrato obrigatório para perfis específicos
  Future<void> salvar(BuildContext context);
}
