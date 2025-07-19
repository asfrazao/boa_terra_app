import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../cadastro/cadastro_pastor_screen.dart';
import '../welcome_screen.dart';
import '../cadastro/cadastro_igreja_screen.dart';
import '../../widgets/cultos.dart';
import '../../models/igreja_model.dart';
import '../../utils/compartilhador_convite.dart';
import '../../screens/dashboard/subscreens/admin_usuario_screen.dart';
import '../dashboard/subscreens/visualizar_pedidos_oracao_screen.dart';
import 'subscreens/gerenciar_eventos_screen.dart';
import '../dashboard/subscreens/recados_screen.dart';

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
  int recadosNaoLidos = 0;
  int pedidosOracaoNaoLidos = 0;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _carregarNomeIgreja();
    _contarRecadosNaoLidos();
    _contarPedidosOracaoNaoLidos();
  }

  Future<void> _carregarDadosUsuario() async {
    if (widget.userId.trim().isEmpty) {
      debugPrint('❌ userId vazio. Cancelando carregamento.');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .get();

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
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
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

      final usuarios = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('convite', isEqualTo: convite)
          .get();

      for (var u in usuarios.docs) {
        batch.delete(u.reference);
      }

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


  Future<void> _contarRecadosNaoLidos() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('mensagens')
          .where('igrejaId', isEqualTo: widget.igrejaId)
          .where('visivelPara', arrayContains: 'pastor')
          .where('dataExpiracao', isGreaterThan: Timestamp.now())
          .get();

      final naoLidos = snapshot.docs.where((doc) {
        final lidasPor = doc.data().containsKey('lidasPor')
            ? List<String>.from(doc['lidasPor'])
            : <String>[];
        return !lidasPor.contains(widget.userId);
      }).length;

      if (!mounted) return;
      setState(() {
        recadosNaoLidos = naoLidos;
      });
    } catch (e) {
      debugPrint("Erro ao contar recados de pastores: $e");
    }
  }

  Future<void> _contarPedidosOracaoNaoLidos() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('pedidos_oracao')
          .where('igrejaId', isEqualTo: widget.igrejaId)
          .where('visivelPara', arrayContains: 'pastor')
          .where('dataExpiracao', isGreaterThan: Timestamp.now())
          .get();

      final naoLidos = snapshot.docs.where((doc) {
        final lidasPor = doc.data().containsKey('lidasPor')
            ? List<String>.from(doc['lidasPor'])
            : <String>[];
        return !lidasPor.contains(widget.userId);
      }).length;

      if (!mounted) return;
      setState(() {
        pedidosOracaoNaoLidos = naoLidos;
      });
    } catch (e) {
      debugPrint("Erro ao contar pedidos de oração não lidos: $e");
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple[100]),
            child: const Text('Sim, Sair'),
          ),
        ],
      ),
    );
  }

  Widget _botaoDash(String titulo, IconData icone, VoidCallback onTap, {int badge = 0}) {
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

  Widget _listaIgrejasAdmin() {
    if (igrejasDoConvite.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
  /*      const Divider(),*/
/*        const Text("Igrejas vinculadas ao seu convite:", style: TextStyle(fontWeight: FontWeight.bold)),*/
        const SizedBox(height: 3),
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
        const SizedBox(height: 10),
/*        const Divider(),*/
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administração do Pastor"),
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
            Text("Olá Pastor ${widget.nome}, bem-vindo ao BOA TERRA.", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            /*Text(nomeIgrejaAtual ?? 'Carregando...', style: const TextStyle(fontSize: 16, color: Colors.grey)),*/
            const SizedBox(height: 10),

            _listaIgrejasAdmin(),

            _botaoDash("Cultos", Icons.schedule, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CultosScreen(igrejaId: widget.igrejaId),
                ),
              );
            }),

            _botaoDash("Recados", Icons.mail, () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecadosScreen(
                    userId: widget.userId,
                    igrejaId: widget.igrejaId,
                  ),
                ),
              );
              _contarRecadosNaoLidos(); // manter contador funcionando
            }, badge: recadosNaoLidos),


            _botaoDash(
              "Gerenciar Eventos",
              Icons.event_available,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GerenciarEventosScreen(
                      igrejaId: widget.igrejaId,
                      userId: widget.userId,
                    ),
                  ),
                );
              },
            ),


            _botaoDash("Visualizar Pedidos de Oração", Icons.favorite, () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VisualizarPedidosOracaoScreen(
                    igrejaId: widget.igrejaId,
                    userId: widget.userId,
                    tipoUsuario: 'pastor',
                  ),
                ),
              );
              _contarPedidosOracaoNaoLidos(); // atualizar após retorno
            }, badge: pedidosOracaoNaoLidos),

            if (conviteVinculado != null)

              _botaoDash("Administrar Obreiros e Membros", Icons.groups, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminUsuariosScreen(
                      convite: conviteVinculado!,
                      userId: widget.userId,
                    ),
                  ),
                );
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

            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
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
            ),
          ],
        ),
      ),
    );
  }
}
