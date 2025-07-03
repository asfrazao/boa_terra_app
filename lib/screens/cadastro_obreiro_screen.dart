import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import '../widgets/imagem_selfie_widget.dart';
import 'cadastro_usuario_dados_screen.dart';

class CadastroObreiroScreen extends StatefulWidget {
  const CadastroObreiroScreen({super.key});

  @override
  State<CadastroObreiroScreen> createState() => _CadastroObreiroScreenState();
}

class _CadastroObreiroScreenState extends State<CadastroObreiroScreen> {
  final TextEditingController chaveController = TextEditingController();
  final List<String> chavesValidas = [
    'BOATERRA2025X',
    'BOATERRAADM01',
    'BOATERRA1A2B3C'
  ];

  bool chaveValidada = false;
  String? chaveAtual;
  String? igrejaSelecionada;
  List<Map<String, dynamic>> igrejas = [];

  Future<void> validarChave() async {
    final chave = chaveController.text.trim().toUpperCase();
    if (!chavesValidas.contains(chave)) {
      setState(() {
        chaveValidada = false;
        igrejas = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Chave inválida')),
      );
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('igrejas')
        .where('chave', isEqualTo: chave)
        .get();

    final lista = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'nome': data['denominacao'] ?? 'Sem nome',
        'admin_setor': data['admin_setor'] ?? '',
      };
    }).toList();

    setState(() {
      chaveValidada = true;
      chaveAtual = chave;
      igrejas = lista;
    });
  }

  void avancarParaFoto() {
    if (igrejaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Selecione a igreja')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => ImagemSelfieWidget(
        onImagemSelecionada: (base64) {
          Navigator.pop(context);
          final igreja = igrejas.firstWhere((i) => i['id'] == igrejaSelecionada);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CadastroUsuarioDadosScreen(
                tipo: 'obreiro',
                idIgreja: igrejaSelecionada!,
                nomeIgreja: igreja['nome'] as String,
                imagemBase64: base64,
              ),
            ),
          );
        },
        onCancelar: () {
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Obreiro'),
        backgroundColor: Colors.deepPurple.shade100,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo ao cadastro de obreiros!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'BOA TERRA',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.deepPurple),
            ),
            const SizedBox(height: 30),
            if (!chaveValidada) ...[
              const Text('Podemos iniciar seu cadastro?'),
              const SizedBox(height: 10),
              TextFormField(
                controller: chaveController,
                decoration: const InputDecoration(
                  labelText: 'Informe a Chave da Igreja ou Convite',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: validarChave,
                icon: const Icon(Icons.vpn_key),
                label: const Text('Validar Chave ou Convite'),
              ),
            ],
            if (chaveValidada && igrejas.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Selecione a igreja em que você é obreiro:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                value: igrejaSelecionada,
                items: igrejas.map<DropdownMenuItem<String>>((igreja) {
                  final nome = igreja['nome'] as String;
                  final setor = igreja['admin_setor'] as String;
                  final textoExibido = setor.isNotEmpty ? '$nome | $setor' : nome;
                  return DropdownMenuItem<String>(
                    value: igreja['id'] as String,
                    child: Text(textoExibido),
                  );
                }).toList(),
                onChanged: (valor) => setState(() => igrejaSelecionada = valor),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: avancarParaFoto,
                child: const Text('Avançar'),
              ),
            ],
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                );
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
            )
          ],
        ),
      ),
    );
  }
}
