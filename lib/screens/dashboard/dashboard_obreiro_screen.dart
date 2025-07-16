import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../cadastro/cadastro_obreiro_screen.dart';
import '../../widgets/cultos.dart';
import '../welcome_screen.dart';
import '../dashboard/subscreens/mensagens_recebidas_screen.dart';

class DashboardObreiroScreen extends StatefulWidget {
  final String nome;
  final String igrejaNome;
  final String igrejaId;
  final String userId;

  const DashboardObreiroScreen({
    super.key,
    required this.userId,
    required this.nome,
    required this.igrejaNome,
    required this.igrejaId,
  });

  @override
  State<DashboardObreiroScreen> createState() => _DashboardObreiroScreenState();
}

class _DashboardObreiroScreenState extends State<DashboardObreiroScreen> {
  Map<String, dynamic>? dadosUsuario;
  int mensagensNaoLidas = 0;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _contarMensagensNaoLidas();
  }

  Future<void> _carregarDadosUsuario() async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.userId)
        .get();

    if (doc.exists) {
      setState(() {
        dadosUsuario = doc.data();
      });
    }
  }

  Future<void> _contarMensagensNaoLidas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('mensagens')
        .where('igrejaId', isEqualTo: widget.igrejaId)
        .where('dataExpiracao', isGreaterThan: Timestamp.now())
        .where('visivelPara', arrayContains: 'obreiro')
        .get();

    int total = 0;
    for (final doc in snapshot.docs) {
      final lidas = doc.data().toString().contains('lidasPor')
          ? List<String>.from(doc['lidasPor'])
          : <String>[];
      if (!lidas.contains(widget.userId)) {
        total++;
      }
    }

    if (mounted) {
      setState(() {
        mensagensNaoLidas = total;
      });
    }
  }

  Widget _botaoDash(String titulo, IconData icone, VoidCallback onTap, {int? badge}) {
    return Card(
      child: ListTile(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icone, size: 32),
            if (badge != null && badge > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
            'Você perderá o acesso à plataforma como obreiro. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(widget.userId)
                  .delete();

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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple[100]),
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
        title: const Text("Dashboard do Obreiro"),
        backgroundColor: Colors.deepPurple.shade100,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Olá ${widget.nome}, bem-vindo ao BOA TERRA.",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(widget.igrejaNome,
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 24),

              _botaoDash("Cultos", Icons.access_time, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CultosScreen(igrejaId: widget.igrejaId),
                  ),
                );
              }),

              _botaoDash("Ler Recados do Pastor", Icons.mail, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MensagensRecebidasScreen(
                      userId: widget.userId,
                      igrejaId: widget.igrejaId,
                      tipoUsuario: 'obreiro',
                    ),
                  ),
                ).then((_) => _contarMensagensNaoLidas());
              }, badge: mensagensNaoLidas),


              _botaoDash("Ver Pedidos de Oração", Icons.favorite_border, () {
                // TODO: Implementar leitura dos pedidos de oração
              }),
              _botaoDash("Eventos e Programações", Icons.event, () {
                // TODO: Implementar eventos
              }),

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
                          builder: (_) => CadastroObreiroScreen(
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
