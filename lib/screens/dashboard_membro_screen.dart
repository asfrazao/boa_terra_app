import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cadastro_membro_screen.dart';
import 'welcome_screen.dart';
import 'cultos_screen.dart';

class DashboardMembroScreen extends StatefulWidget {
  final String nome;
  final String igrejaId;
  final String igrejaNome;
  final String userId;

  const DashboardMembroScreen({
    super.key,
    required this.nome,
    required this.igrejaId,
    required this.igrejaNome,
    required this.userId,
  });

  @override
  State<DashboardMembroScreen> createState() => _DashboardMembroScreenState();
}

class _DashboardMembroScreenState extends State<DashboardMembroScreen> {
  int recadosNaoLidos = 0;
  int eventosNaoLidos = 0;
  Map<String, dynamic>? dadosUsuario;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _contarRecadosNaoLidos();
    _contarEventosNaoLidos();
  }

  Future<void> _carregarDadosUsuario() async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(widget.userId).get();
    if (doc.exists) {
      setState(() {
        dadosUsuario = doc.data();
      });
    }
  }

  Future<void> _contarRecadosNaoLidos() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('recados')
          .where('destinatarios', arrayContains: widget.userId)
          .get();

      final naoLidos = snapshot.docs.where((doc) {
        final lidos = List<String>.from(doc['lidos'] ?? []);
        return !lidos.contains(widget.userId);
      }).length;

      if (!mounted) return;
      setState(() {
        recadosNaoLidos = naoLidos;
      });
    } catch (e) {
      debugPrint("Erro ao contar recados: $e");
    }
  }

  Future<void> _contarEventosNaoLidos() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('eventos')
          .where('igrejaId', isEqualTo: widget.igrejaId)
          .get();

      final naoLidos = snapshot.docs.where((doc) {
        final lidos = List<String>.from(doc['lidos'] ?? []);
        return !lidos.contains(widget.userId);
      }).length;

      if (!mounted) return;
      setState(() {
        eventosNaoLidos = naoLidos;
      });
    } catch (e) {
      debugPrint("Erro ao contar eventos: $e");
    }
  }

  Widget _buildBotaoDash(String titulo, IconData icone, VoidCallback onTap, {int badge = 0}) {
    return Card(
      child: ListTile(
        leading: Stack(
          children: [
            Icon(icone, size: 32),
            if (badge > 0)
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              )
          ],
        ),
        title: Text(titulo),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Cadastro'),
        content: const Text(
            'Seu cadastro será excluído da igreja. Você não terá mais acesso aos eventos, recados e pedidos de oração. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('usuarios').doc(widget.userId).delete();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Cadastro excluído com sucesso.')),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                );
              }
            },
            icon: const Icon(Icons.delete),
            label: const Text('Sim, Excluir'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard do Membro'),
        backgroundColor: Colors.purple.shade100,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Olá ${widget.nome}, bem-vindo ao BOA TERRA.',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(widget.igrejaNome, style: const TextStyle(fontSize: 16, color: Colors.grey)),

              const SizedBox(height: 24),
              _buildBotaoDash('Cultos', Icons.access_time, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CultosScreen(igrejaId: widget.igrejaId),
                  ),
                );
              }),
              _buildBotaoDash('Recados do Pastor', Icons.announcement, () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => RecadosScreen(userId: widget.userId),
                ));
              }, badge: recadosNaoLidos),
              _buildBotaoDash('Pedidos de Oração', Icons.volunteer_activism, () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PedidoOracaoScreen(userId: widget.userId),
                ));
              }),
              _buildBotaoDash('Eventos', Icons.event, () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => EventosScreen(userId: widget.userId),
                ));
              }, badge: eventosNaoLidos),

              const SizedBox(height: 24),
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
                          builder: (_) => CadastroMembroScreen(
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
                    onPressed: _confirmarExclusao,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Telas de exemplo — substitua pelas reais
class RecadosScreen extends StatelessWidget {
  final String userId;
  const RecadosScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Recados")), body: const Center(child: Text("Recados em breve")));
  }
}

class PedidoOracaoScreen extends StatelessWidget {
  final String userId;
  const PedidoOracaoScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Pedidos de Oração")), body: const Center(child: Text("Pedidos em breve")));
  }
}

class EventosScreen extends StatelessWidget {
  final String userId;
  const EventosScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Eventos")), body: const Center(child: Text("Eventos em breve")));
  }
}
