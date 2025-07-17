import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boa_terra_app/services/pedido_oracao_service.dart';

class PedidoOracaoScreen extends StatefulWidget {
  final String userId;
  final String igrejaId;

  const PedidoOracaoScreen({super.key, required this.userId, required this.igrejaId});

  @override
  State<PedidoOracaoScreen> createState() => _PedidoOracaoScreenState();
}

class _PedidoOracaoScreenState extends State<PedidoOracaoScreen> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController mensagemController = TextEditingController();
  bool salvando = false;

  @override
  void dispose() {
    tituloController.dispose();
    mensagemController.dispose();
    super.dispose();
  }

  Future<void> _enviarPedido() async {
    final titulo = tituloController.text.trim();
    final mensagem = mensagemController.text.trim();

    if (titulo.isEmpty || mensagem.isEmpty) return;

    setState(() => salvando = true);

    await PedidoOracaoService().enviarPedido(
      igrejaId: widget.igrejaId,
      userId: widget.userId,
      titulo: titulo,
      mensagem: mensagem,
    );

    setState(() {
      tituloController.clear();
      mensagemController.clear();
      salvando = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Pedido de oração enviado com sucesso!')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos de Oração')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Pedido de Oração para:',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mensagemController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Mensagem',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: salvando ? null : _enviarPedido,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Pedidos de Oração para:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pedidos_oracao')
                    .where('enviadoPor', isEqualTo: widget.userId)
                    .where('dataExpiracao', isGreaterThan: Timestamp.now())
                    .orderBy('enviadoPor') // 🔥 necessário para funcionar
                    .orderBy('dataExpiracao')
                    .orderBy('dataEnvio', descending: true)
                    .snapshots(),
              builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('Nenhum pedido enviado ainda.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final titulo = doc['titulo'] ?? '';
                      final mensagem = doc['mensagem'] ?? '';
                      final data = (doc['dataEnvio'] as Timestamp).toDate();
                      return ListTile(
                        title: Text(titulo),
                        subtitle: Text(
                          'Enviado em: ${data.day}/${data.month} às ${data.hour}:${data.minute.toString().padLeft(2, '0')}',
                        ),
                        onTap: () async {
                          final controllerTitulo = TextEditingController(text: titulo);
                          final controllerMensagem = TextEditingController(text: mensagem);
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Editar Pedido'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: controllerTitulo,
                                    decoration: const InputDecoration(
                                      labelText: 'Pedido de Oração para:',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: controllerMensagem,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      labelText: 'Mensagem',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Salvar'),
                                ),
                              ],
                            ),
                          );

                          if (confirmar == true) {
                            await doc.reference.update({
                              'titulo': controllerTitulo.text.trim(),
                              'mensagem': controllerMensagem.text.trim(),
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✅ Pedido atualizado com sucesso.')),
                              );
                            }
                          }
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Excluir Pedido'),
                                content: const Text('Deseja realmente excluir este pedido de oração?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Sim, Excluir'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmar == true) {
                              await doc.reference.delete();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✅ Pedido excluído com sucesso.')),
                                );
                              }
                            }
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
