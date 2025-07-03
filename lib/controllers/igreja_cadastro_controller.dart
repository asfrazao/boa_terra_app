import 'package:flutter/material.dart';
import '../models/igreja_model.dart';
import '../services/igreja_service.dart';
import '../utils/validador_chave.dart';
import '../utils/validador_convite.dart'; // NOVO

class IgrejaCadastroController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final TextEditingController chaveController = TextEditingController();
  final TextEditingController denominacaoController = TextEditingController();
  final TextEditingController adminController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController pastorNomeController = TextEditingController();
  final TextEditingController pastorSobrenomeController = TextEditingController();
  final TextEditingController coPastorController = TextEditingController();
  final TextEditingController coPastorSobrenomeController = TextEditingController();

  String? estadoSelecionado;
  String? logoBase64;
  bool acessoValidado = false;
  String conviteGerado = ''; // NOVO

  final Map<String, List<TimeOfDay>> horariosCulto = {};
  final Map<String, bool> diasSelecionados = {};

  List<IgrejaModel> igrejasEncontradas = [];
  IgrejaModel? igrejaSelecionada;

  final _service = IgrejaService();

  IgrejaCadastroController() {
    for (var dia in [
      'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
    ]) {
      diasSelecionados[dia] = false;
      horariosCulto[dia] = [];
    }
  }

  /// Valida a chave digitada e busca igrejas vinculadas
  /// Retorna true se a chave for válida, false caso contrário
  Future<bool> validarChave() async {
    final chave = chaveController.text.trim().toUpperCase();

    if (!ValidadorChaveLocal.validar(chave)) {
      acessoValidado = false;
      igrejasEncontradas.clear();
      notifyListeners();
      return false;
    }

    igrejasEncontradas = await _service.buscarPorChave(chave);
    acessoValidado = true;

    // Gera o convite automaticamente
    conviteGerado = ValidadorConvite.gerarConvite('IGREJA'); // CORRETO temporariamente


    notifyListeners();
    return true;
  }

  void preencherCampos(IgrejaModel igreja) {
    igrejaSelecionada = igreja;
    denominacaoController.text = igreja.denominacao;
    adminController.text = igreja.adminSetor ?? '';
    estadoSelecionado = igreja.estado;
    cidadeController.text = igreja.cidade;
    bairroController.text = igreja.bairro;
    enderecoController.text = igreja.endereco;
    numeroController.text = igreja.numero;
    pastorNomeController.text = igreja.pastorNome;
    pastorSobrenomeController.text = igreja.pastorSobrenome;
    coPastorController.text = igreja.coPastor ?? '';
    coPastorSobrenomeController.text = igreja.coPastorSobrenome ?? '';
    logoBase64 = igreja.logoBase64;
    conviteGerado = igreja.convite ?? ''; // NOVO

    for (var dia in diasSelecionados.keys) {
      diasSelecionados[dia] = false;
      horariosCulto[dia] = [];
    }

    for (var culto in igreja.diasCultos) {
      final dia = culto['dia'];
      final horaStr = culto['horario'];
      if (dia != null && horaStr != null) {
        final partes = horaStr.split(':');
        final hora = int.tryParse(partes[0]) ?? 19;
        final minuto = int.tryParse(partes[1]) ?? 30;
        diasSelecionados[dia] = true;
        horariosCulto[dia]?.add(TimeOfDay(hour: hora, minute: minuto));
      }
    }

    notifyListeners();
  }

  Future<void> salvarCadastro() async {
    if (chaveController.text.trim().isEmpty) return;

    final List<Map<String, String>> cultos = [];
    diasSelecionados.forEach((dia, ativo) {
      if (ativo) {
        for (var hora in horariosCulto[dia]!) {
          cultos.add({
            'dia': dia,
            'horario': '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}',
          });
        }
      }
    });

    final nova = IgrejaModel(
      id: igrejaSelecionada?.id,
      chave: chaveController.text.trim().toUpperCase(),
      denominacao: denominacaoController.text.trim(),
      estado: estadoSelecionado ?? '',
      cidade: cidadeController.text.trim(),
      bairro: bairroController.text.trim(),
      endereco: enderecoController.text.trim(),
      numero: numeroController.text.trim(),
      pastorNome: pastorNomeController.text.trim(),
      pastorSobrenome: pastorSobrenomeController.text.trim(),
      adminSetor: adminController.text.trim(),
      coPastor: coPastorController.text.trim(),
      coPastorSobrenome: coPastorSobrenomeController.text.trim(),
      diasCultos: cultos,
      logoBase64: logoBase64 ?? '',
      dataCadastro: DateTime.now(),
      convite: conviteGerado, // NOVO
    );

    await _service.salvarOuAtualizar(nova);
    await validarChave(); // recarrega lista após salvar
  }

  Future<void> excluirIgreja(String id) async {
    await _service.excluir(id);
    await validarChave(); // recarrega após exclusão
  }
}
