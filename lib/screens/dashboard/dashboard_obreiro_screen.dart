import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../cadastro/cadastro_obreiro_screen.dart';
import '../../widgets/cultos.dart';
import '../welcome_screen.dart';
import '../dashboard/subscreens/mensagens_recebidas_screen.dart';
import 'subscreens/pedido_oracao_screen.dart';
import '../dashboard/subscreens/eventos_recebidos_screen.dart';
import '../../utils/compartilhador_convite.dart';

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
  String? conviteVinculado;
  String? cidade;
  String? estado;
  int mensagensNaoLidas = 0;
  int pedidosNaoLidos = 0;
  int eventosNaoLidos = 0;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _contarMensagensNaoLidas();
    _contarPedidosNaoLidos();
    _contarEventosNaoLidos();
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
        final igrejaSnap = await FirebaseFirestore.instance
            .collection('igrejas')
            .where('convite', isEqualTo: conviteVinculado)
            .limit(1)
            .get();
        if (igrejaSnap.docs.isNotEmpty) {
          final igreja = igrejaSnap.docs.first.data();
          setState(() {
            cidade = igreja['cidade'];
            estado = igreja['estado'];
          });
        }
      }
    }
  }

  Future<void> _contarMensagensNaoLidas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('mensagens')
        .where('igrejaId', isEqualTo: widget.igrejaId)
        .where('visivelPara', arrayContains: 'obreiro')
        .where('dataExpiracao', isGreaterThan: Timestamp.now())
        .get();

    final count = snapshot.docs.where((doc) {
      final lidasPor = doc.data().containsKey('lidasPor') ? List<String>.from(doc['lidasPor']) : [];
      return !lidasPor.contains(widget.userId);
    }).length;

    setState(() => mensagensNaoLidas = count);
  }

  Future<void> _contarPedidosNaoLidos() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('pedidos_oracao')
        .where('igrejaId', isEqualTo: widget.igrejaId)
        .where('visivelPara', arrayContains: 'obreiro')
        .where('dataExpiracao', isGreaterThan: Timestamp.now())
        .get();

    final count = snapshot.docs.where((doc) {
      final lidasPor = doc.data().containsKey('lidasPor') ? List<String>.from(doc['lidasPor']) : [];
      return !lidasPor.contains(widget.userId);
    }).length;

    setState(() => pedidosNaoLidos = count);
  }

  Future<void> _contarEventosNaoLidos() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('eventos')
        .where('igrejaId', isEqualTo: widget.igrejaId)
        .where('visivelPara', arrayContains: 'obreiro')
        .where('dataExpiracao', isGreaterThan: Timestamp.now())
        .get();

    final count = snapshot.docs.where((doc) {
      final lidasPor = doc.data().containsKey('lidasPor') ? List<String>.from(doc['lidasPor']) : [];
      return !lidasPor.contains(widget.userId);
    }).length;

    setState(() => eventosNaoLidos = count);
  }

  Widget _botao(String titulo, IconData icone, VoidCallback onTap, {int badge = 0}) {
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
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 10)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard do Obreiro"),
        backgroundColor: Colors.purple.shade100,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 5),
            Text("Olá ${widget.nome}, bem-vindo ao BOA TERRA.", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (cidade != null && estado != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${widget.igrejaNome}\n$cidade, $estado", style: const TextStyle(color: Colors.grey)),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.green),
                    tooltip: 'Compartilhar convite',
                    onPressed: () async {
                      if (conviteVinculado != null) {
                        await CompartilhadorConvite.compartilharConvite(
                          convite: conviteVinculado!,
                          nomeIgreja: widget.igrejaNome,

                        );
                      }
                    },
                  ),
                ],
              ),

            const SizedBox(height: 8),

            _botao("Cultos", Icons.schedule, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CultosScreen(igrejaId: widget.igrejaId),
                ),
              );
            }),

            _botao("Ler Recados do Pastor", Icons.mail, () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MensagensRecebidasScreen(
                    userId: widget.userId,
                    igrejaId: widget.igrejaId,
                    tipoUsuario: 'obreiro',
                  ),
                ),
              );
              _contarMensagensNaoLidas();
            }, badge: mensagensNaoLidas),

            _botao("Pedidos de Oração", Icons.favorite, () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PedidoOracaoScreen(
                    userId: widget.userId,
                    igrejaId: widget.igrejaId,
                  ),
                ),
              );
              _contarPedidosNaoLidos();
            }),

            _botao("Eventos", Icons.event, () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventosRecebidosScreen(
                    userId: widget.userId,
                    igrejaId: widget.igrejaId,
                  ),
                ),
              );
              _contarEventosNaoLidos();
            }, badge: eventosNaoLidos),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Editar Cadastro"),
                  onPressed: () {
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
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Excluir Cadastro"),
                        content: const Text("Você perderá acesso ao aplicativo. Deseja continuar?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Excluir"),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      await FirebaseFirestore.instance.collection('usuarios').doc(widget.userId).delete();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                              (route) => false,
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.exit_to_app),
                label: const Text("Sair"),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        (route) => false,
                  );
                },
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
