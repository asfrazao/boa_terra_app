import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MensagensRecebidasScreen extends StatefulWidget {
  final String userId;
  final String igrejaId;
  final String tipoUsuario; // 'pastor', 'obreiro' ou 'membro'

  const MensagensRecebidasScreen({
    super.key,
    required this.userId,
    required this.igrejaId,
    required this.tipoUsuario,
  });

  @override
  State<MensagensRecebidasScreen> createState() => _MensagensRecebidasScreenState();
}

class _MensagensRecebidasScreenState extends State<MensagensRecebidasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recados do Pastor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('mensagens')
              .where('igrejaId', isEqualTo: widget.igrejaId)
              .where('visivelPara', arrayContains: widget.tipoUsuario)
              .where('dataExpiracao', isGreaterThan: Timestamp.now())
              .orderBy('dataExpiracao') // 🔹 obrigatório junto ao where >
              .orderBy('dataEnvio', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Center(child: Text('Nenhuma mensagem disponível.'));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final titulo = doc['titulo'] ?? '';
                final mensagem = doc['mensagem'] ?? '';
                final dataEnvio = (doc['dataEnvio'] as Timestamp).toDate();
                final lidasPor = doc.data().toString().contains('lidasPor')
                    ? List<String>.from(doc['lidasPor'])
                    : <String>[];

                final bool lida = lidasPor.contains(widget.userId);

                return ListTile(
                  title: Text(
                    titulo,
                    style: TextStyle(
                      fontWeight: lida ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Enviado em: ${dataEnvio.day}/${dataEnvio.month} às ${dataEnvio.hour}:${dataEnvio.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(titulo),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mensagem),
                            const SizedBox(height: 16),
                            Text(
                              'Enviado em: ${dataEnvio.day}/${dataEnvio.month}/${dataEnvio.year} às ${dataEnvio.hour}:${dataEnvio.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.grey),
                            ),
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
                      });
                    }
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
