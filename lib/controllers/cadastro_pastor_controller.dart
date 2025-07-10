import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CadastroPastorController extends ChangeNotifier {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController rgController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController repetirSenhaController = TextEditingController();

  String? igrejaSelecionada;
  String? convite;
  String? igrejaNome;
  String? igrejaId;

  // Imagem e base64
  XFile? imagem;
  String? _imagemBase64Final;

  String? get imagemBase64 => _imagemBase64Final;
  set imagemBase64(String? valor) {
    _imagemBase64Final = valor;
    notifyListeners();
  }

  // Batismo (mesmo que em membros, valor fixo por enquanto)
  String? batismoSelecionado = 'Não informado';

  // Papéis exclusivos
  bool isOficial = false;
  bool isCoPastor = false;
  bool isAuxiliar = false;

  Map<String, bool> get funcoesSelecionadas => {
    'Pastor Oficial': isOficial,
    'Co-Pastor': isCoPastor,
    'Auxiliar': isAuxiliar,
  };

  /// Torna os papéis mutuamente exclusivos
  void alternarFuncao(String funcao, bool valor) {
    if (!valor) {
      isOficial = false;
      isCoPastor = false;
      isAuxiliar = false;
    } else {
      isOficial = funcao == 'Pastor Oficial';
      isCoPastor = funcao == 'Co-Pastor';
      isAuxiliar = funcao == 'Auxiliar';
    }
    notifyListeners();
  }

  Map<String, dynamic> toFirestoreData() {
    return {
      'nome': nomeController.text,
      'nome_lower': nomeController.text.toLowerCase(),
      'sobrenome': sobrenomeController.text,
      'sobrenome_lower': sobrenomeController.text.toLowerCase(),
      'rg': rgController.text,
      'email': emailController.text,
      'senha': senhaController.text,
      'imagem': _imagemBase64Final ?? '',
      'convite': convite,
      'igrejaId': igrejaId,
      'igrejaNome': igrejaNome,
      'Pastor Oficial': isOficial,
      'Co-Pastor': isCoPastor,
      'Auxiliar': isAuxiliar,
      'batismo': batismoSelecionado,
      'dataCadastro': DateTime.now(),
      'dataAtualizacao': DateTime.now(),
    };
  }

  void carregarDadosExistentes(Map<String, dynamic> dados) {
    nomeController.text = dados['nome'] ?? '';
    sobrenomeController.text = dados['sobrenome'] ?? '';
    rgController.text = dados['rg'] ?? '';
    emailController.text = dados['email'] ?? '';
    senhaController.text = dados['senha'] ?? '';
    repetirSenhaController.text = dados['senha'] ?? '';
    _imagemBase64Final = dados['imagem'];
    convite = dados['convite'];
    igrejaId = dados['igrejaId'];
    igrejaNome = dados['igrejaNome'];
    igrejaSelecionada = igrejaId;
    isOficial = dados['Pastor Oficial'] ?? false;
    isCoPastor = dados['Co-Pastor'] ?? false;
    isAuxiliar = dados['Auxiliar'] ?? false;
    notifyListeners();
  }

  void limpar() {
    nomeController.clear();
    sobrenomeController.clear();
    rgController.clear();
    emailController.clear();
    senhaController.clear();
    repetirSenhaController.clear();
    imagem = null;
    _imagemBase64Final = null;
    convite = null;
    igrejaId = null;
    igrejaNome = null;
    igrejaSelecionada = null;
    isOficial = false;
    isCoPastor = false;
    isAuxiliar = false;
    notifyListeners();
  }
}
