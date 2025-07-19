import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boa_terra_app/models/enums/validade_mensagem.dart';

class EnviarMensagemScreen extends StatefulWidget {
  final String userId;
  final String igrejaId;
  final Map<String, dynamic>? mensagemExistente;
  final String? mensagemId;
  final bool mostrarHistorico;

  const EnviarMensagemScreen({
    super.key,
    required this.userId,
    required this.igrejaId,
    this.mensagemExistente,
    this.mensagemId,
    this.mostrarHistorico = true,
  });

  @override
  State<EnviarMensagemScreen> createState() => _EnviarMensagemScreenState();
}

class _EnviarMensagemScreenState extends State<EnviarMensagemScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _mensagemController = TextEditingController();

  Map<String, bool> destinatarios = {
    'Todos': false,
    'Pastores': false,
    'Obreiros': false,
    'Membros': false,
  };

  @override
  void initState() {
    super.initState();
    if (widget.mensagemExistente != null) {
      _tituloController.text = widget.mensagemExistente!['titulo'] ?? '';
      _mensagemController.text = widget.mensagemExistente!['mensagem'] ?? '';
    }
  }

  void _limparTela() {
    _tituloController.clear();
    _mensagemController.clear();
    setState(() {
      destinatarios.updateAll((key, value) => false);
    });
  }

  void _selecionarDestinatario(String chave) {
    setState(() {
      if (chave == 'Todos') {
        destinatarios.updateAll((key, value) => key == 'Todos');
      } else {
        destinatarios['Todos'] = false;
        destinatarios[chave] = !destinatarios[chave]!;
      }
    });
  }

  String? _obterDestinatarioSelecionado() {
    final selecionados =
    destinatarios.entries.where((entry) => entry.value).toList();
    return selecionados.isNotEmpty ? selecionados.first.key : null;
  }

  List<String> _mapearDestinatarioParaLista(String tipo) {
    switch (tipo) {
      case 'Todos':
        return ['pastor', 'obreiro', 'membro'];
      case 'Pastores':
        return ['pastor'];
      case 'Obreiros':
        return ['obreiro'];
      case 'Membros':
        return ['membro'];
      default:
        return [];
    }
  }

  void _mostrarAlerta(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  void _enviarMensagem() async {
    final destino = _obterDestinatarioSelecionado();
    final titulo = _tituloController.text.trim();
    final mensagem = _mensagemController.text.trim();

    if (destino == null) {
      _mostrarAlerta('Selecione ao menos um destinatário.');
      return;
    }

    if (titulo.isEmpty) {
      _mostrarAlerta('Digite o título da mensagem.');
      return;
    }

    if (mensagem.isEmpty) {
      _mostrarAlerta('Digite a mensagem antes de enviar.');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar envio'),
        content: Text('A mensagem será enviada para: $destino.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final dataEnvio = DateTime.now();
              final dataExpiracao =
              dataEnvio.add(ValidadeMensagem.mensagemPadrao.duracao);

              try {
                if (widget.mensagemId != null) {
                  await FirebaseFirestore.instance
                      .collection('mensagens')
                      .doc(widget.mensagemId)
                      .update({
                    'titulo': titulo,
                    'mensagem': mensagem,
                  });
                  _mostrarAlerta('✅ Mensagem atualizada com sucesso!');
                } else {
                  await FirebaseFirestore.instance.collection('mensagens').add({
                    'titulo': titulo,
                    'mensagem': mensagem,
                    'dataEnvio': Timestamp.fromDate(dataEnvio),
                    'dataExpiracao': Timestamp.fromDate(dataExpiracao),
                    'enviadoPor': widget.userId,
                    'igrejaId': widget.igrejaId,
                    'visivelPara': _mapearDestinatarioParaLista(destino),
                    'lidasPor': [],
                  });
                  _mostrarAlerta('✅ Mensagem enviada com sucesso!');
                }

                _limparTela();
              } catch (e) {
                _mostrarAlerta('Erro ao enviar a mensagem: $e');
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(String mensagemId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Mensagem'),
        content: const Text('Sua mensagem será definitivamente excluída.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance.collection('mensagens').doc(mensagemId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Mensagem excluída com sucesso!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar Recados')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Selecione o destinatário:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 5,
              children: destinatarios.entries.map((entry) {
                return FilterChip(
                  label: Text(entry.key),
                  selected: entry.value,
                  onSelected: (_) => _selecionarDestinatario(entry.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _mensagemController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar'),
                    onPressed: _enviarMensagem,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
