import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boa_terra_app/models/enums/validade_mensagem.dart';

class EnviarMensagemScreen extends StatefulWidget {
  final String userId;
  final String igrejaId;

  const EnviarMensagemScreen({
    super.key,
    required this.userId,
    required this.igrejaId,
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
                await FirebaseFirestore.instance.collection('mensagens').add({
                  'titulo': titulo,
                  'mensagem': mensagem,
                  'dataEnvio': Timestamp.fromDate(dataEnvio),
                  'dataExpiracao': Timestamp.fromDate(dataExpiracao),
                  'enviadoPor': widget.userId,
                  'igrejaId': widget.igrejaId,
                  'visivelPara': _mapearDestinatarioParaLista(destino),
                  'lidasPor': [], // ✅ ESSENCIAL para que a lógica funcione
                });


                _mostrarAlerta('✅ Mensagem enviada com sucesso!');
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

  void _abrirDetalhesMensagem({
    required String id,
    required String titulo,
    required String mensagem,
    required DateTime dataEnvio,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mensagem, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Text(
                'Enviado em: ${dataEnvio.day}/${dataEnvio.month}/${dataEnvio.year} às ${dataEnvio.hour}:${dataEnvio.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Editar mensagem',
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.pop(context);
                      _editarMensagem(id, titulo, mensagem);
                    },
                  ),
                  IconButton(
                    tooltip: 'Excluir mensagem',
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmarExclusao(id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _editarMensagem(String id, String tituloAtual, String mensagemAtual) {
    final tituloController = TextEditingController(text: tituloAtual);
    final mensagemController = TextEditingController(text: mensagemAtual);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Mensagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: mensagemController,
              decoration: const InputDecoration(labelText: 'Mensagem'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('mensagens')
                  .doc(id)
                  .update({
                'titulo': tituloController.text.trim(),
                'mensagem': mensagemController.text.trim(),
              });
              Navigator.pop(context);
              _mostrarAlerta('Mensagem atualizada com sucesso!');
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Sua mensagem será definitivamente excluída.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('mensagens')
                  .doc(id)
                  .delete();
              Navigator.pop(context);
              _mostrarAlerta('Sua mensagem foi excluída com sucesso');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar Recado')),
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
            const Align(
              alignment: Alignment.centerLeft,
              child:
              Text('Título:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                hintText: 'Digite o título da mensagem...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Mensagem:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _mensagemController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Digite sua mensagem aqui...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _enviarMensagem,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _limparTela();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mensagens Enviadas:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mensagens')
                    .where('enviadoPor', isEqualTo: widget.userId)
                    .where('igrejaId', isEqualTo: widget.igrejaId)
                    .where('dataExpiracao', isGreaterThan: Timestamp.now())
                    .orderBy('dataExpiracao', descending: false)
                    .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                        child: Text('Nenhuma mensagem enviada ainda.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final titulo = doc['titulo'] ?? '';
                      final mensagem = doc['mensagem'] ?? '';
                      final dataEnvio =
                      (doc['dataEnvio'] as Timestamp).toDate();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(titulo),
                          subtitle: Text(
                            'Enviado em: ${dataEnvio.day}/${dataEnvio.month} às ${dataEnvio.hour}:${dataEnvio.minute.toString().padLeft(2, '0')}',
                          ),
                          onTap: () {
                            _abrirDetalhesMensagem(
                              id: doc.id,
                              titulo: titulo,
                              mensagem: mensagem,
                              dataEnvio: dataEnvio,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
