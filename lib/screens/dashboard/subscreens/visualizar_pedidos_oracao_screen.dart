import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/cadastro_usuario_service.dart';
import 'perfil_usuario_screen.dart';

class VisualizarPedidosOracaoScreen extends StatefulWidget {
  final String igrejaId;
  final String userId;
  final String tipoUsuario;

  const VisualizarPedidosOracaoScreen({
    super.key,
    required this.igrejaId,
    required this.userId,
    required this.tipoUsuario,
  });

  @override
  State<VisualizarPedidosOracaoScreen> createState() => _VisualizarPedidosOracaoScreenState();
}

class _VisualizarPedidosOracaoScreenState extends State<VisualizarPedidosOracaoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos de Oração Recebidos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pedidos_oracao')
              .where('igrejaId', isEqualTo: widget.igrejaId)
              .where('visivelPara', arrayContains: widget.tipoUsuario)
              .where('dataExpiracao', isGreaterThan: Timestamp.now())
              .orderBy('dataExpiracao')
              .orderBy('dataEnvio', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text('Nenhum pedido recebido até o momento.'));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final titulo = doc['titulo'] ?? '';
                final data = (doc['dataEnvio'] as Timestamp).toDate();
                final enviadoPor = doc['enviadoPor'] ?? '';
                final dataMap = doc.data();
                final lidasPor = (dataMap != null && dataMap is Map<String, dynamic> && dataMap.containsKey('lidasPor'))
                    ? List<String>.from(dataMap['lidasPor'])
                    : <String>[];

                final lida = lidasPor.contains(widget.userId);

                // 🔒 Verifica remetente antes de chamar FutureBuilder
                if (enviadoPor.isEmpty) {
                  return const ListTile(
                    title: Text('❌ Pedido com remetente inválido'),
                    subtitle: Text('Campo "enviadoPor" não preenchido.'),
                  );
                }

                return FutureBuilder<Map<String, dynamic>?>(
                  future: CadastroUsuarioService().buscarUsuarioPorId(enviadoPor),
                  builder: (context, usuarioSnapshot) {
                    if (usuarioSnapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        title: Text('Carregando...'),
                        dense: true, // deixa visualmente mais discreto
                      );
                    }

                    if (!usuarioSnapshot.hasData || usuarioSnapshot.data == null) {
                      return const SizedBox.shrink(); // esconde o item se algo falhar
                    }


                    final usuario = usuarioSnapshot.data!;
                    final nomeUsuario = '${usuario['nome']} ${usuario['sobrenome']}';
                    final dataFormatada = DateFormat("dd/MM 'às' HH:mm").format(data);

                    return ListTile(
                      title: Text(
                        'Pedidos de Orações de: $nomeUsuario\nPedido em: $dataFormatada',
                        style: TextStyle(fontWeight: lida ? FontWeight.normal : FontWeight.bold),
                      ),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PerfilUsuarioScreen(dadosUsuario: usuario),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Pedido de oração de: $nomeUsuario',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirmar = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Excluir Pedido'),
                                        content: const Text('Deseja realmente excluir este pedido de oração?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
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
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('✅ Pedido excluído com sucesso.')),
                                        );
                                      }
                                    }
                                  },
                                )
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Para: $titulo', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(doc['mensagem'] ?? ''),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Fechar'),
                              ),
                            ],
                          ),
                        );

                        if (!lida) {
                          await doc.reference.update({
                            'lidasPor': FieldValue.arrayUnion([widget.userId])
                          }).catchError((e) {
                            debugPrint('Erro ao marcar como lido: $e');
                          });
                        }
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
