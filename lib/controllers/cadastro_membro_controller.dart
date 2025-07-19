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

  /// Getters seguros com trim para uso em persistência
  String get nomeSanitizado => nomeController.text.trim();
  String get sobrenomeSanitizado => sobrenomeController.text.trim();
  String get rgSanitizado => rgController.text.trim();
  String get emailSanitizado => emailController.text.trim();
  String get senhaSanitizada => senhaController.text.trim();
  String get repetirSenhaSanitizada => repetirSenhaController.text.trim();

  /// Método chamado ao selecionar grupo
  void selecionarGrupo(String grupo) {
    grupoSelecionado = grupo;
    funcoesSelecionadas.clear();
    notifyListeners();
  }

  /// Alterna funções marcadas no grupo
  void alternarFuncao(String funcao, bool selecionado) {
    if (funcao == 'Nenhum') {
      if (selecionado) {
        // 🔁 Desativa todas as outras funções
        funcoesPorGrupo[grupoSelecionado]?.forEach((f) {
          funcoesSelecionadas[f] = (f == 'Nenhum');
        });
      } else {
        funcoesSelecionadas['Nenhum'] = false;
      }
    } else {
      funcoesSelecionadas[funcao] = selecionado;

      if (selecionado && funcoesSelecionadas['Nenhum'] == true) {
        // ❌ Se outro for selecionado, desmarca "Nenhum"
        funcoesSelecionadas['Nenhum'] = false;
      }
    }

    notifyListeners();
  }

  /// Carrega dados ao editar um membro já existente
  void carregarDadosExistentes(Map<String, dynamic> dados) {
    nomeController.text = dados['nome'] ?? '';
    sobrenomeController.text = dados['sobrenome'] ?? '';
    rgController.text = dados['rg'] ?? '';
    emailController.text = dados['email'] ?? '';
    batismo = dados['batismo'] ?? 'Sim';
    imagemBase64 = dados['imagem'];
    idIgreja = dados['igrejaId'];
    convite = dados['convite'];

    if (dados.containsKey('grupo')) {
      grupoSelecionado = dados['grupo'];
    }

    for (final key in dados.keys) {
      if (key != 'grupo' &&
          key != 'imagem' &&
          key != 'nome' &&
          key != 'sobrenome' &&
          key != 'rg' &&
          key != 'email' &&
          key != 'senha' &&
          key != 'batismo' &&
          key != 'convite' &&
          key != 'igrejaId' &&
          key != 'igrejaNome') {
        final valor = dados[key];
        if (valor is bool) {
          funcoesSelecionadas[key] = valor;
        }
      }
    }
  }

  void disposeControllers() {
    nomeController.dispose();
    sobrenomeController.dispose();
    rgController.dispose();
    emailController.dispose();
    senhaController.dispose();
    repetirSenhaController.dispose();
  }
}
