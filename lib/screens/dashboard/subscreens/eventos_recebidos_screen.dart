import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventosRecebidosScreen extends StatefulWidget {
  final String userId;
  final String igrejaId;

  const EventosRecebidosScreen({
    super.key,
    required this.userId,
    required this.igrejaId,
  });

  @override
  State<EventosRecebidosScreen> createState() => _EventosRecebidosScreenState();
}

class _EventosRecebidosScreenState extends State<EventosRecebidosScreen> {
  late Future<List<QueryDocumentSnapshot>> _eventosFuture;

  @override
  void initState() {
    super.initState();
    _eventosFuture = _carregarEventos();
  }

  Future<List<QueryDocumentSnapshot>> _carregarEventos() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('eventos')
        .where('igrejaId', isEqualTo: widget.igrejaId)
        .where('visivelPara', arrayContainsAny: ['membro', 'todos'])
        .where('dataExpiracao', isGreaterThan: Timestamp.now())
        .orderBy('igrejaId')
        .orderBy('dataExpiracao')
        .orderBy('dataEvento')
        .get();

    return snapshot.docs;
  }

  Future<void> _marcarComoLido(String docId, List<String> lidasPor) async {
    if (!lidasPor.contains(widget.userId)) {
      lidasPor.add(widget.userId);
      await FirebaseFirestore.instance.collection('eventos').doc(docId).update({
        'lidasPor': lidasPor,
      });
    }
  }

  void _mostrarDetalhesEvento(QueryDocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final lidasPor = List<String>.from(data['lidasPor'] ?? []);
    await _marcarComoLido(doc.id, lidasPor);

    final titulo = data['titulo'] ?? '';
    final mensagem = data['mensagem'] ?? '';
    final dataEvento = (data['dataEvento'] as Timestamp).toDate();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mensagem),
            const SizedBox(height: 8),
            Text(
              'Data do Evento: ${dataEvento.day}/${dataEvento.month}/${dataEvento.year} às ${dataEvento.hour}h${dataEvento.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Fechar'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _eventosFuture = _carregarEventos(); // atualiza a tela
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos da Igreja')),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _eventosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum evento disponível.'));
          }

          final eventos = snapshot.data!;
          return ListView.builder(
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final doc = eventos[index];
              final data = doc.data() as Map<String, dynamic>;
              final titulo = data['titulo'] ?? '';
              final dataEvento = (data['dataEvento'] as Timestamp).toDate();
              final lidasPor = List<String>.from(data['lidasPor'] ?? []);
              final lido = lidasPor.contains(widget.userId);

              return ListTile(
                title: Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: lido ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${dataEvento.day}/${dataEvento.month} às ${dataEvento.hour}h${dataEvento.minute.toString().padLeft(2, '0')}',
                ),
                onTap: () => _mostrarDetalhesEvento(doc),
              );
            },
          );
        },
      ),
    );
  }
}
