import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dashboard_membro_screen.dart';
import 'dashboard_obreiro_screen.dart';
import 'dashboard_pastor_screen.dart';
import 'register_type_screen.dart';
import 'solicitar_chave_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController primeiroNomeController = TextEditingController();
  final TextEditingController ultimoSobrenomeController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool carregando = false;
  bool _senhaVisivel = false;

  void realizarLogin() async {
    final nome = primeiroNomeController.text.trim().toLowerCase();
    final sobrenome = ultimoSobrenomeController.text.trim().toLowerCase();
    final senha = senhaController.text.trim();

    if (nome.isEmpty || sobrenome.isEmpty || senha.isEmpty) {
      _mostrarErro("Preencha todos os campos.");
      return;
    }

    if (sobrenome.split(' ').length > 1) {
      _mostrarErro("Use apenas o último sobrenome (sem espaços).");
      return;
    }

    setState(() => carregando = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('nome_lower', isEqualTo: nome)
          .where('sobrenome_lower', isEqualTo: sobrenome)
          .get();

      if (snapshot.docs.isEmpty) {
        _mostrarErro("Nome ou senha inválidos.");
        setState(() => carregando = false);
        return;
      }

      final userDoc = snapshot.docs.first;
      final dados = userDoc.data();
      final userId = userDoc.id;

      if (dados['senha'] != senha) {
        _mostrarErro("Nome ou senha inválidos.");
        setState(() => carregando = false);
        return;
      }

      final tipo = dados['tipo'];
      final nomeIgreja = dados['nome_igreja'] ?? 'Igreja não definida';
      final igrejaId = dados['igrejaId'] ?? '';

      Widget telaDestino;
      if (tipo == 'membro') {
        telaDestino = DashboardMembroScreen(
          nome: dados['nome'],
          igrejaNome: nomeIgreja,
          igrejaId: igrejaId,
          userId: userId,
        );
      } else if (tipo == 'obreiro') {
        telaDestino = DashboardObreiroScreen(
          nome: dados['nome'],
          igrejaNome: nomeIgreja,
        );
      } else if (tipo == 'pastor') {
        telaDestino = DashboardPastorScreen(
          nome: dados['nome'],
          igrejaNome: nomeIgreja,
        );
      } else {
        _mostrarErro("Tipo de acesso inválido.");
        setState(() => carregando = false);
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => telaDestino),
      );
    } catch (e) {
      _mostrarErro("Erro ao validar login: $e");
    }

    setState(() => carregando = false);
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/logoIADB.jpeg', height: 120),
              const SizedBox(height: 24),
              const Text(
                'Bem-vindo ao BOA TERRA APP!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: primeiroNomeController,
                decoration: const InputDecoration(
                  labelText: 'Primeiro Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ultimoSobrenomeController,
                decoration: const InputDecoration(
                  labelText: 'Último Sobrenome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: senhaController,
                obscureText: !_senhaVisivel,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _senhaVisivel = !_senhaVisivel;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: carregando ? null : realizarLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade50,
                      foregroundColor: Colors.purple,
                    ),
                    child: carregando
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Entrar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterTypeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade50,
                      foregroundColor: Colors.purple,
                    ),
                    child: const Text('Cadastrar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SolicitarChaveScreen()),
                  );
                },
                child: const Text(
                  'Solicite sua Chave de Acesso',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  const url = 'https://oteologo.com.br';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
                },
                child: const Text(
                  'Conheça também O TEOLOGO',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
