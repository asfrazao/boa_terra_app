import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cadastro_pastor_screen.dart';
import 'welcome_screen.dart';
import 'cadastro_igreja_screen.dart';
import '../models/igreja_model.dart';
import '../utils/compartilhador_convite.dart';

class DashboardPastorScreen extends StatefulWidget {
  final String nome;
  final String igrejaId;
  final String igrejaNome;
  final String userId;

  const DashboardPastorScreen({
    super.key,
    required this.nome,
    required this.igrejaId,
    required this.igrejaNome,
    required this.userId,
  });

  @override
  State<DashboardPastorScreen> createState() => _DashboardPastorScreenState();
}

class _DashboardPastorScreenState extends State<DashboardPastorScreen> {
  Map<String, dynamic>? dadosUsuario;
  String? nomeIgrejaAtual;
  String? conviteVinculado;
  List<IgrejaModel> igrejasDoConvite = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _carregarNomeIgreja();
  }

  Future<void> _carregarDadosUsuario() async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(widget.userId).get();
    if (doc.exists) {
      final dados = doc.data();
      setState(() {
        dadosUsuario = dados;
        conviteVinculado = dados?['convite'];
      });
      if (conviteVinculado != null) {
        _carregarIgrejasDoConvite(conviteVinculado!);
      }
    }
  }

  Future<void> _carregarNomeIgreja() async {
    final snap = await FirebaseFirestore.instance.collection('igrejas').doc(widget.igrejaId).get();
    if (snap.exists) {
      setState(() {
        nomeIgrejaAtual = snap.data()?['denominacao'] ?? 'Igreja não definida';
      });
    } else {
      setState(() {
        nomeIgrejaAtual = 'Igreja não definida';
      });
    }
  }

  Future<void> _carregarIgrejasDoConvite(String convite) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('igrejas')
        .where('convite', isEqualTo: convite)
        .get();

    setState(() {
      igrejasDoConvite = snapshot.docs.map((doc) {
        return IgrejaModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> _excluirIgrejaComConfirmacao(IgrejaModel igreja) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Igreja'),
        content: const Text(
            'Atenção, você irá excluir a Igreja, Pastores, Membros e Obreiros. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final convite = igreja.convite;
      final batch = FirebaseFirestore.instance.batch();

      // Deleta todos os usuários da igreja (pastores, membros, obreiros)
      final usuarios = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('convite', isEqualTo: convite)
          .get();

      for (var u in usuarios.docs) {
        batch.delete(u.reference);
      }

      // Deleta a igreja
      batch.delete(FirebaseFirestore.instance.collection('igrejas').doc(igreja.id));

      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Igreja e usuários removidos.')),
        );
        _carregarIgrejasDoConvite(conviteVinculado!);
      }
    }
  }

  void _confirmarExclusaoUsuario() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Cadastro'),
        content: const Text(
            'Seu cadastro será excluído da igreja. Você não terá mais acesso às funcionalidades administrativas. Deseja continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Sim, Excluir'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('usuarios').doc(widget.userId).delete();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmarSaida() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair do BOA TERRA?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Sim, Sair'),
          ),
        ],
      ),
    );
  }

  Widget _botaoDash(String titulo, IconData icone, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icone, size: 32),
        title: Text(titulo),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget _listaIgrejasAdmin() {
    if (igrejasDoConvite.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text("Igrejas vinculadas ao seu convite:",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...igrejasDoConvite.map((igreja) {
          return ListTile(
            title: Text(igreja.denominacao),
            subtitle: Text('${igreja.cidade}, ${igreja.estado}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.green),
                  tooltip: 'Compartilhar convite',
                  onPressed: () async {
                    await CompartilhadorConvite.compartilharConvite(
                      convite: igreja.convite!,
                      nomeIgreja: igreja.denominacao,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Editar igreja',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CadastroIgrejaScreen(igrejaEditavel: igreja),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Excluir igreja',
                  onPressed: () => _excluirIgrejaComConfirmacao(igreja),
                ),
              ],
            ),
          );
        }).toList(),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard do Pastor"),
        backgroundColor: Colors.purple.shade100,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dadosUsuario?['fotoBase64'] != null)
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: MemoryImage(base64Decode(dadosUsuario!['fotoBase64'])),
                ),
              ),
            const SizedBox(height: 16),
            Text("Olá ${widget.nome}, bem-vindo ao BOA TERRA.",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(nomeIgrejaAtual ?? 'Carregando...',
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),

            _botaoDash("Enviar Recados", Icons.message, () {}),
            _botaoDash("Gerenciar Eventos", Icons.event_available, () {}),
            _botaoDash("Visualizar Pedidos de Oração", Icons.favorite, () {}),
            _botaoDash("Administrar Obreiros e Membros", Icons.groups, () {}),

            _listaIgrejasAdmin(),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Editar Cadastro"),
                  onPressed: dadosUsuario == null
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CadastroPastorScreen(
                          dadosPreenchidos: dadosUsuario!,
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text("Excluir Cadastro"),
                  onPressed: _confirmarExclusaoUsuario,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: _confirmarSaida,
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Sair'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
