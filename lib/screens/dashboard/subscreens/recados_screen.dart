import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'enviar_mensagem_screen.dart';

class RecadosScreen extends StatefulWidget {
  final String userId;
  final String igrejaId;

  const RecadosScreen({super.key, required this.userId, required this.igrejaId});

  @override
  State<RecadosScreen> createState() => _RecadosScreenState();
}

class _RecadosScreenState extends State<RecadosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _navegarParaNovaMensagem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnviarMensagemScreen(
          userId: widget.userId,
          igrejaId: widget.igrejaId,
          mostrarHistorico: false,
        ),
      ),
    );
  }

  void _voltarParaDashboard() {
    Navigator.pop(context);
  }

  Widget _mensagensRecebidasTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mensagens')
          .where('igrejaId', isEqualTo: widget.igrejaId)
          .where('visivelPara', arrayContains: 'pastor')
          .where('enviadoPor', isNotEqualTo: widget.userId)
          .where('dataExpiracao', isGreaterThan: Timestamp.now())
          .orderBy('enviadoPor')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final mensagens = snapshot.data!.docs;
        if (mensagens.isEmpty) {
          return const Center(child: Text("Nenhum recado recebido."));
        }

        return ListView.builder(
          itemCount: mensagens.length,
          itemBuilder: (context, index) {
            final doc = mensagens[index];
            final data = doc.data() as Map<String, dynamic>;
            final titulo = data['titulo'] ?? '';
            final lidasPor = List<String>.from(data['lidasPor'] ?? []);
            final lida = lidasPor.contains(widget.userId);

            return ListTile(
              title: Text(
                titulo,
                style: TextStyle(fontWeight: lida ? FontWeight.normal : FontWeight.bold),
              ),
              subtitle: Text("De: outro pastor - ${DateFormat('dd/MM/yyyy HH:mm').format((data['dataEnvio'] as Timestamp).toDate())}"),
              onTap: () => _mostrarDetalhesMensagem(doc.id, data),
            );
          },
        );
      },
    );
  }

  void _mostrarDetalhesMensagem(String mensagemId, Map<String, dynamic> data) async {
    final lidasPor = List<String>.from(data['lidasPor'] ?? []);
    if (!lidasPor.contains(widget.userId)) {
      await FirebaseFirestore.instance.collection('mensagens').doc(mensagemId).update({
        'lidasPor': [...lidasPor, widget.userId],
      });
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(data['titulo'] ?? ''),
        content: Text(data['mensagem'] ?? ''),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }

  Widget _mensagensEnviadasTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mensagens')
          .where('igrejaId', isEqualTo: widget.igrejaId)
          .where('enviadoPor', isEqualTo: widget.userId)
          .orderBy('dataEnvio', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final mensagens = snapshot.data!.docs;
        if (mensagens.isEmpty) {
          return const Center(child: Text("Nenhum recado enviado."));
        }

        return ListView.builder(
          itemCount: mensagens.length,
          itemBuilder: (context, index) {
            final doc = mensagens[index];
            final data = doc.data() as Map<String, dynamic>;
            final titulo = data['titulo'] ?? '';
            final dataEnvio = (data['dataEnvio'] as Timestamp).toDate();
            final formato = DateFormat('dd/MM/yyyy HH:mm');

            return ListTile(
              title: Text(titulo),
              subtitle: Text("Enviado em ${formato.format(dataEnvio)}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmarExclusao(doc.id),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnviarMensagemScreen(
                    userId: widget.userId,
                    igrejaId: widget.igrejaId,
                    mensagemExistente: data,
                    mensagemId: doc.id,
                  ),
                ),
              ),
            );
          },
        );
      },
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
      appBar: AppBar(
        title: const Text("Recados"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Recebidos"),
            Tab(text: "Enviados"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _mensagensRecebidasTab(),
          _mensagensEnviadasTab(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Nova Mensagem"),
                onPressed: _navegarParaNovaMensagem,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("Voltar"),
                onPressed: _voltarParaDashboard,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
