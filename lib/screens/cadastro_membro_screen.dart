import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/validador_convite.dart';
import '../services/cadastro_usuario_service.dart';
import '../helpers/compact_image_helper.dart';
import '../widgets/campo_senha.dart';
import '../controllers/cadastro_membro_controller.dart';
import 'dashboard_membro_screen.dart';
import 'welcome_screen.dart';

class CadastroMembroScreen extends StatefulWidget {
  final Map<String, dynamic>? dadosPreenchidos;
  final String? userId;

  const CadastroMembroScreen({super.key, this.dadosPreenchidos, this.userId});

  @override
  State<CadastroMembroScreen> createState() => _CadastroMembroScreenState();
}

class _CadastroMembroScreenState extends State<CadastroMembroScreen> {
  final controller = CadastroMembroController();
  final parte1 = TextEditingController();
  final parte2 = TextEditingController();
  final foco1 = FocusNode();
  final foco2 = FocusNode();
  final FocusNode _focusRG = FocusNode();

  int etapaAtual = 0;
  bool salvando = false;
  bool carregandoImagem = false;

  List<Map<String, dynamic>> igrejas = [];
  String? conviteAtual;

  final Map<String, List<String>> funcoesPorGrupo = {
    'Grupo das irmãs': ['Lider', 'Regência', 'Consagração', 'Louvor', 'Nenhum'],
    'Grupo dos jovens': ['Lider', 'Regência', 'Louvor', 'Nenhum'],
    'Grupo dos adolescentes': ['Lider', 'Regência', 'Louvor', 'Nenhum'],
    'Grupo das crianças': ['Lider', 'Regência', 'Louvor', 'Nenhum'],
  };

  String get conviteFormatado =>
      'BOATERRA-${parte1.text.toUpperCase()}-${parte2.text.toUpperCase()}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => foco1.requestFocus());

    // Validação do último sobrenome (igual ao pastor)
    _focusRG.addListener(() {
      if (_focusRG.hasFocus) {
        final sobrenome = controller.sobrenomeController.text.trim();
        if (sobrenome.split(' ').length > 1) {
          controller.sobrenomeController.clear();

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Atenção"),
              content: const Text("Use apenas o último sobrenome."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      }
    });

    if (widget.dadosPreenchidos != null) {
      controller.carregarDadosExistentes(widget.dadosPreenchidos!);
      conviteAtual = widget.dadosPreenchidos!['convite'];

      if (controller.idIgreja != null) {
        FirebaseFirestore.instance
            .collection('igrejas')
            .doc(controller.idIgreja)
            .get()
            .then((doc) {
          if (doc.exists) {
            final data = doc.data()!;
            setState(() {
              igrejas = [
                {
                  'id': doc.id,
                  'nome': data['denominacao'] ?? 'Sem nome',
                  'admin_setor': data['admin_setor'] ?? '',
                }
              ];
            });
          }
        });
      }

      etapaAtual = 3;
    }
  }


  Future<void> validarConvite() async {
    final convite = conviteFormatado;

    if (!ValidadorConvite.validar(convite)) {
      _mostrarSnack('❌ Convite inválido');
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('igrejas')
        .where('convite', isEqualTo: convite)
        .get();

    if (snapshot.docs.isEmpty) {
      _mostrarSnack('⚠️ Convite não encontrado');
      return;
    }

    final lista = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'nome': data['denominacao'] ?? 'Sem nome',
        'admin_setor': data['admin_setor'] ?? '',
      };
    }).toList();

    setState(() {
      conviteAtual = convite;
      igrejas = lista;
      etapaAtual = 1;
    });
  }

  Future<void> tirarSelfie() async {
    setState(() => carregandoImagem = true);
    final base64 = await CompactImageHelper.selecionarDaCamera();
    setState(() => carregandoImagem = false);

    if (base64 != null) {
      setState(() {
        controller.imagemBase64 = base64;
        etapaAtual = 3;
      });
    } else {
      _mostrarSnack('❌ Não foi possível processar a imagem');
    }
  }

  Future<void> carregarFotoGaleria() async {
    setState(() => carregandoImagem = true);
    final base64 = await CompactImageHelper.selecionarDaGaleria();
    setState(() => carregandoImagem = false);

    if (base64 != null) {
      setState(() {
        controller.imagemBase64 = base64;
        etapaAtual = 3;
      });
    } else {
      _mostrarSnack('❌ Não foi possível processar a imagem');
    }
  }

  void _mostrarOpcoesImagem() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar nova selfie'),
                onTap: () async {
                  Navigator.pop(context);
                  await tirarSelfie();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Buscar nova imagem'),
                onTap: () async {
                  Navigator.pop(context);
                  await carregarFotoGaleria();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> salvar() async {
    if (controller.idIgreja == null || controller.imagemBase64 == null) {
      _mostrarSnack('⚠️ Selecione a igreja e adicione a imagem');
      return;
    }

    setState(() => salvando = true);

    final igrejaSelecionadaMap = igrejas.firstWhere(
          (i) => i['id'] == controller.idIgreja,
      orElse: () => {'nome': 'Igreja desconhecida', 'admin_setor': ''},
    );

    final sucesso = await CadastroUsuarioService.salvarCadastro(
      context: context,
      userId: widget.userId,
      tipo: 'membro',
      convite: conviteAtual!,
      idIgreja: controller.idIgreja!,
      nomeIgreja: igrejaSelecionadaMap['nome'] ?? '',
      adminSetor: igrejaSelecionadaMap['admin_setor'] ?? '',
      imagemBase64: controller.imagemBase64!,
      nome: controller.nomeController.text,
      sobrenome: controller.sobrenomeController.text,
      rg: controller.rgController.text,
      email: controller.emailController.text,
      senha: controller.senhaController.text,
      repetirSenha: controller.repetirSenhaController.text,
      batismo: controller.batismo,
      grupo: controller.grupoSelecionado,
      extrasSelecionados: controller.funcoesSelecionadas,
    );

    if (sucesso && mounted) {
      _mostrarSnack('✅ Cadastro salvo com sucesso!');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardMembroScreen(
            nome: controller.nomeController.text,
            igrejaNome: igrejaSelecionadaMap['nome'] ?? '',
            igrejaId: controller.idIgreja!,
            userId: widget.userId ?? '',
          ),
        ),
            (route) => false,
      );
    }


    setState(() => salvando = false);
  }

  void _irParaDashboard(String userId) {
    final nome = controller.nomeController.text;
    final igrejaNome = igrejas.firstWhere(
          (i) => i['id'] == controller.idIgreja,
      orElse: () => {'nome': 'Igreja desconhecida'},
    )['nome'] ?? '';

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardMembroScreen(
          nome: nome,
          igrejaId: controller.idIgreja!,
          igrejaNome: igrejaNome,
          userId: userId,
        ),
      ),
          (route) => false,
    );
  }

  void _mostrarSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _etapaConvite() => Column(
    children: [
      const Text('Informe o convite gerado pela igreja:'),
      const SizedBox(height: 12),
      Row(
        children: [
          const Text('BOATERRA-',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(
            width: 60,
            child: TextField(
              controller: parte1,
              focusNode: foco1,
              maxLength: 3,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(counterText: ''),
              onChanged: (text) {
                if (text.length == 3) foco2.requestFocus();
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: TextField(
              controller: parte2,
              focusNode: foco2,
              maxLength: 3,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Center(
        child: ElevatedButton.icon(
          onPressed: validarConvite,
          icon: const Icon(Icons.vpn_key),
          label: const Text('Validar Convite'),
        ),
      ),
    ],
  );

  Widget _etapaIgreja() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Selecione a igreja em que você é membro:'),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: igrejas.any((i) => i['id'] == controller.idIgreja)
            ? controller.idIgreja
            : null,
        isExpanded: true,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        items: igrejas.map((igreja) {
          final nome = igreja['nome'] as String;
          final setor = igreja['admin_setor'] as String;
          final texto = setor.isNotEmpty ? '$nome | $setor' : nome;
          return DropdownMenuItem<String>(
            value: igreja['id'] as String,
            child: Text(texto),
          );
        }).toList(),
        onChanged: (val) => setState(() => controller.idIgreja = val),
      ),
      const SizedBox(height: 24),
      Center(
        child: ElevatedButton.icon(
          onPressed: () {
            if (controller.idIgreja == null) {
              _mostrarSnack('⚠️ Selecione a igreja');
              return;
            }
            setState(() => etapaAtual = 2);
          },
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Avançar'),
        ),
      ),
    ],
  );

  Widget _etapaImagem() => carregandoImagem
      ? const Center(child: CircularProgressIndicator())
      : Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Escolha uma imagem:'),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: tirarSelfie,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tirar Selfie'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: carregarFotoGaleria,
              icon: const Icon(Icons.photo),
              label: const Text('Buscar Imagem'),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _etapaFormulario() => Column(
    children: [
      const Text("Foto Selecionada:"),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _mostrarOpcoesImagem,
        child: CircleAvatar(
          radius: 60,
          backgroundImage:
          MemoryImage(base64Decode(controller.imagemBase64!)),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
          controller: controller.nomeController,
          decoration: const InputDecoration(labelText: "Primeiro Nome")),
      const SizedBox(height: 12),
      TextFormField(
          controller: controller.sobrenomeController,
          decoration: const InputDecoration(labelText: "Último Nome")),
      const SizedBox(height: 12),
      TextFormField(
        controller: controller.rgController,
        focusNode: _focusRG,
        decoration: const InputDecoration(labelText: "RG"),),
      const SizedBox(height: 12),
      TextFormField(
          controller: controller.emailController,
          decoration: const InputDecoration(labelText: "Email"),
          keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: controller.batismo,
        decoration: const InputDecoration(labelText: "Batizado?"),
        items: const [
          DropdownMenuItem(value: "Sim", child: Text("Sim")),
          DropdownMenuItem(value: "Não", child: Text("Não")),
        ],
        onChanged: (value) =>
            setState(() => controller.batismo = value ?? 'Não'),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: controller.grupoSelecionado,
        decoration: const InputDecoration(
            labelText: "A qual grupo o irmão(ã) pertence?"),
        items: const [
          DropdownMenuItem(
              value: 'Grupo das irmãs', child: Text('Grupo das irmãs')),
          DropdownMenuItem(
              value: 'Grupo dos jovens', child: Text('Grupo dos jovens')),
          DropdownMenuItem(
              value: 'Grupo dos adolescentes',
              child: Text('Grupo dos adolescentes')),
          DropdownMenuItem(
              value: 'Grupo das crianças',
              child: Text('Grupo das crianças')),
          DropdownMenuItem(value: 'Nenhum', child: Text('Nenhum')),
        ],
        onChanged: (grupo) {
          setState(() {
            controller.selecionarGrupo(grupo ?? '');
          });
        },
      ),
      const SizedBox(height: 12),
      if (controller.grupoSelecionado != null &&
          controller.grupoSelecionado != 'Nenhum')
        Column(
          children: [
            const Divider(),
            const Text('Funções no grupo:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...funcoesPorGrupo[controller.grupoSelecionado]!.map((opcao) {
              return CheckboxListTile(
                title: Text(opcao),
                value: controller.funcoesSelecionadas[opcao] ?? false,
                onChanged: (value) {
                  setState(() {
                    controller.alternarFuncao(opcao, value ?? false);
                  });
                },
              );
            }).toList(),
          ],
        ),
      const SizedBox(height: 12),
      CampoSenha(
        senhaController: controller.senhaController,
        repetirSenhaController: controller.repetirSenhaController,
      ),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: salvar,
        icon: const Icon(Icons.save),
        label: const Text("Finalizar Cadastro"),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    Widget conteudo;
    switch (etapaAtual) {
      case 0:
        conteudo = _etapaConvite();
        break;
      case 1:
        conteudo = _etapaIgreja();
        break;
      case 2:
        conteudo = _etapaImagem();
        break;
      case 3:
        conteudo = _etapaFormulario();
        break;
      default:
        conteudo = const Text('Etapa inválida');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Membro'),
        backgroundColor: Colors.deepPurple.shade100,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text('Bem-vindo ao cadastro de membros!',
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('BOA TERRA',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.deepPurple)),
                  const SizedBox(height: 30),
                  conteudo,
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WelcomeScreen()),
                            (route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                  ),
                ],
              ),
            ),
          ),
          if (salvando)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    parte1.dispose();
    parte2.dispose();
    foco1.dispose();
    foco2.dispose();
    _focusRG.dispose();
    controller.dispose();
    super.dispose();
  }
}
