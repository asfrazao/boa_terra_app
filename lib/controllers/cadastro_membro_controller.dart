import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastroMembroController extends ChangeNotifier {
  // Campos básicos de qualquer usuário
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController rgController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController repetirSenhaController = TextEditingController();

  // Campos específicos de membro
  String? batismo = 'Sim'; // valor padrão
  String? imagemBase64;
  String? idIgreja;
  String? convite;

  // Grupo e funções (específicos do perfil membro)
  String? grupoSelecionado;
  final Map<String, bool> funcoesSelecionadas = {};

  final Map<String, List<String>> funcoesPorGrupo = {
    'Grupo das irmãs': ['Lider', 'Regência', 'Consagração', 'Louvor', 'Nenhum'],
    'Grupo dos jovens': ['Lider', 'Regência', 'Louvor', 'Nenhum'],
    'Grupo dos adolescentes': ['Lider', 'Regência', 'Louvor', 'Nenhum'],
    'Grupo das crianças': ['Lider', 'Regência', 'Louvor', 'Nenhum'],
  };

  bool get senhaValida => senhaController.text.trim().length >= 6;
  bool get repetidaCorretamente => senhaController.text == repetirSenhaController.text;

  bool validarCamposObrigatorios() {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$');

    return nomeController.text.trim().isNotEmpty &&
        sobrenomeController.text.trim().isNotEmpty &&
        rgController.text.trim().isNotEmpty &&
        emailRegex.hasMatch(emailController.text.trim()) &&
        (imagemBase64 != null && imagemBase64!.isNotEmpty) &&
        (idIgreja != null && idIgreja!.isNotEmpty) &&
        (batismo != null) &&
        senhaValida &&
        repetidaCorretamente;
  }

  /// Retorna um mapa com os dados do membro prontos para salvar no Firestore
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
      'batismo': batismo ?? 'Não informado',
      'igrejaId': idIgreja,
      'igrejaNome': nomeIgreja,
      'setorAdmin': adminSetor,
      'convite': convite,
    };

    if (!isEditando) {
      dados['senha'] = senhaController.text.trim();
      dados['dataCadastro'] = FieldValue.serverTimestamp();
    } else {
      if (senhaValida) dados['senha'] = senhaController.text.trim();
      dados['dataAtualizacao'] = FieldValue.serverTimestamp();
    }

    if (grupoSelecionado != null && grupoSelecionado != 'Nenhum') {
      dados['grupo'] = grupoSelecionado;
      for (final funcao in funcoesPorGrupo[grupoSelecionado] ?? []) {
        dados[funcao] = funcoesSelecionadas[funcao] ?? false;
      }
    }

    return dados;
  }

  void atualizarFuncoesSelecionadas(Map<String, bool> novas) {
    funcoesSelecionadas
      ..clear()
      ..addAll(novas);
    notifyListeners();
  }

  void selecionarGrupo(String grupo) {
    grupoSelecionado = grupo;
    funcoesSelecionadas.clear();
    notifyListeners();
  }

  void alternarFuncao(String funcao, bool selecionado) {
    if (funcao == 'Nenhum') {
      if (selecionado) {
        funcoesSelecionadas.clear();
        funcoesSelecionadas['Nenhum'] = true;
      } else {
        funcoesSelecionadas.remove('Nenhum');
      }
    } else {
      funcoesSelecionadas[funcao] = selecionado;
      if (funcoesSelecionadas['Nenhum'] == true) {
        funcoesSelecionadas.remove('Nenhum');
      }
    }
    notifyListeners();
  }

  void limpar() {
    nomeController.clear();
    sobrenomeController.clear();
    rgController.clear();
    emailController.clear();
    senhaController.clear();
    repetirSenhaController.clear();
    batismo = 'Sim';
    imagemBase64 = null;
    idIgreja = null;
    grupoSelecionado = null;
    convite = null;
    funcoesSelecionadas.clear();
    notifyListeners();
  }

  void carregarDadosExistentes(Map<String, dynamic> dados) {
    nomeController.text = dados['nome'] ?? '';
    sobrenomeController.text = dados['sobrenome'] ?? '';
    rgController.text = dados['rg'] ?? '';
    emailController.text = dados['email'] ?? '';
    imagemBase64 = dados['imagem'];
    idIgreja = dados['igrejaId'];
    batismo = dados['batismo'] ?? 'Não';
    grupoSelecionado = dados['grupo'];
    convite = dados['convite'];

    if (grupoSelecionado != null) {
      final funcoes = funcoesPorGrupo[grupoSelecionado!] ?? [];
      for (final f in funcoes) {
        if (dados[f] == true) funcoesSelecionadas[f] = true;
      }
    }
  }
}
