import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'usuario_cadastro_controller.dart';

class CadastroObreiroController extends UsuarioCadastroController {
  // Campos específicos do Obreiro
  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final rgController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final repetirSenhaController = TextEditingController();

  String? cargoSelecionado;
  String? idIgreja;

  /// ✅ Validações
  bool get senhaValida => senhaController.text.trim().length >= 6;
  bool get repetidaCorretamente =>
      senhaController.text.trim() == repetirSenhaController.text.trim();

  bool validarCamposObrigatorios() {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$');

    return nomeController.text.trim().isNotEmpty &&
        sobrenomeController.text.trim().isNotEmpty &&
        rgController.text.trim().isNotEmpty &&
        emailRegex.hasMatch(emailController.text.trim()) &&
        (cargoSelecionado != null && cargoSelecionado!.isNotEmpty) &&
        (imagemBase64 != null && imagemBase64!.isNotEmpty) &&
        (igrejaSelecionada != null && igrejaSelecionada!.isNotEmpty) &&
        senhaValida &&
        repetidaCorretamente;
  }

  /// 📤 Mapeamento dos dados para o Firestore
  Map<String, dynamic> toFirestoreData({
    required String nomeIgreja,
    required String adminSetor,
    required String tipo,
    required String imagemBase64Final,
    required bool isEditando,
  }) {
    final Map<String, dynamic> dados = {
      'tipo': tipo,
      'imagem': imagemBase64Final,
      'nome': nomeController.text.trim(),
      'sobrenome': sobrenomeController.text.trim(),
      'nome_lower': nomeController.text.trim().toLowerCase(),
      'sobrenome_lower': sobrenomeController.text.trim().toLowerCase(),
      'rg': rgController.text.trim(),
      'email': emailController.text.trim(),
      'cargo': cargoSelecionado,
      'igrejaId': idIgreja,
      'igrejaNome': nomeIgreja,
      'setorAdmin': adminSetor,
      'convite': conviteAtual,
    };

    if (!isEditando) {
      dados['senha'] = senhaController.text.trim();
      dados['dataCadastro'] = FieldValue.serverTimestamp();
    } else {
      if (senhaValida) dados['senha'] = senhaController.text.trim();
      dados['dataAtualizacao'] = FieldValue.serverTimestamp();
    }

    return dados;
  }

  /// 🧩 Carrega dados para edição
  void carregarDadosExistentes(Map<String, dynamic> dados) {
    nomeController.text = dados['nome'] ?? '';
    sobrenomeController.text = dados['sobrenome'] ?? '';
    rgController.text = dados['rg'] ?? '';
    emailController.text = dados['email'] ?? '';
    imagemBase64 = dados['imagem'];
    idIgreja = dados['igrejaId'];
    conviteAtual = dados['convite'];
    cargoSelecionado = dados['cargo'];
  }

  /// 🧼 Limpa os campos após conclusão ou cancelamento
  void limpar() {
    nomeController.clear();
    sobrenomeController.clear();
    rgController.clear();
    emailController.clear();
    senhaController.clear();
    repetirSenhaController.clear();
    imagemBase64 = null;
    igrejaSelecionada = null;
    conviteAtual = null;
    cargoSelecionado = null;
    notifyListeners();
  }

  @override
  void dispose() {
    nomeController.dispose();
    sobrenomeController.dispose();
    rgController.dispose();
    emailController.dispose();
    senhaController.dispose();
    repetirSenhaController.dispose();
    super.dispose();
  }

  /// 🔐 Obrigatório da superclasse
  @override
  Future<void> salvar(BuildContext context) {
    throw UnimplementedError('A lógica de salvamento deve ser implementada na tela.');
  }
}
