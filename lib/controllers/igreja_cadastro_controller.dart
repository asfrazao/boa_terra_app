import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/igreja_model.dart';
import '../services/igreja_service.dart';
import '../utils/validador_chave.dart';
import '../utils/validador_convite.dart';
import '../utils/compartilhador_convite.dart';

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
  String conviteGerado = '';

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

  /// Valida a chave localmente e carrega igrejas relacionadas
  Future<bool> validarChave() async {
    final chave = chaveController.text.trim().toUpperCase();

    if (!ValidadorChaveLocal.validar(chave)) {
      acessoValidado = false;
      igrejasEncontradas.clear();
      conviteGerado = '';
      notifyListeners();
      return false;
    }

    igrejasEncontradas = await _service.buscarPorChave(chave);
    acessoValidado = true;

    conviteGerado = ValidadorConvite.gerarConviteTemporario();

    notifyListeners();
    return true;
  }

  /// Preenche os campos para edição de igreja diretamente
  void preencherCamposSeEditar(IgrejaModel? igreja) {
    if (igreja == null) return;

    igrejaSelecionada = igreja;
    acessoValidado = true;

    chaveController.text = igreja.chave;
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
    conviteGerado = igreja.convite ?? '';

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

  /// Preenche os campos a partir da igreja selecionada (em modo padrão)
  void preencherCampos(IgrejaModel igreja) {
    preencherCamposSeEditar(igreja);
  }

  /// Persiste a igreja nova ou atualiza a existente
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
      convite: conviteGerado,
    );

    final idSalvo = await _service.salvarOuAtualizar(nova);

    await FirebaseFirestore.instance.collection('igrejas').doc(idSalvo).update({
      'convite': conviteGerado,
    });

    final snapshotAtualizado = await FirebaseFirestore.instance
        .collection('igrejas')
        .doc(idSalvo)
        .get();

    final dataAtualizada = snapshotAtualizado.data();
    conviteGerado = dataAtualizada?['convite'] ?? conviteGerado;

    await validarChave();

    igrejaSelecionada = igrejasEncontradas.firstWhere(
          (i) => i.id == idSalvo,
      orElse: () => igrejaSelecionada!,
    );

    notifyListeners();
  }

  Future<void> compartilharConvite() async {
    if (conviteGerado.isEmpty) return;

    await CompartilhadorConvite.compartilharConvite(
      convite: conviteGerado,
      nomeIgreja: denominacaoController.text.trim(),
    );
  }

  Future<void> excluirIgreja(String convite) async {
    if (convite.isEmpty) return;

    // Mostra um loading
    showDialog(
      context: formKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Exclui todos os usuários com o mesmo convite
      final snapUsuarios = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('convite', isEqualTo: convite)
          .get();

      for (final doc in snapUsuarios.docs) {
        await doc.reference.delete();
      }

      // Exclui todas as igrejas com o mesmo convite
      final snapIgrejas = await FirebaseFirestore.instance
          .collection('igrejas')
          .where('convite', isEqualTo: convite)
          .get();

      for (final doc in snapIgrejas.docs) {
        await doc.reference.delete();
      }

      // Revalida a chave para atualizar a lista
      await validarChave();

      if (formKey.currentContext!.mounted) {
        Navigator.pop(formKey.currentContext!); // fecha o loading
        ScaffoldMessenger.of(formKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('✅ Igreja e usuários excluídos com sucesso.')),
        );
      }
    } catch (e) {
      Navigator.pop(formKey.currentContext!); // fecha o loading
      if (formKey.currentContext!.mounted) {
        ScaffoldMessenger.of(formKey.currentContext!).showSnackBar(
          SnackBar(content: Text('❌ Erro ao excluir: $e')),
        );
      }
    }
  }

}
