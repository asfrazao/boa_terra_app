import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/campos_cadastro_membro.dart';
import 'welcome_screen.dart';

class CadastroMembroDadosScreen extends StatefulWidget {
  final String idIgreja;
  final String nomeIgreja;
  final String imagemBase64;

  const CadastroMembroDadosScreen({
    super.key,
    required this.idIgreja,
    required this.nomeIgreja,
    required this.imagemBase64,
  });

  @override
  State<CadastroMembroDadosScreen> createState() => _CadastroMembroDadosScreenState();
}

class _CadastroMembroDadosScreenState extends State<CadastroMembroDadosScreen> {
  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final rgController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final repetirSenhaController = TextEditingController();
  String? batismo;
  bool salvando = false;

  Future<void> salvarCadastro() async {
    final nome = nomeController.text.trim();
    final sobrenome = sobrenomeController.text.trim();
    final rg = rgController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();
    final repetirSenha = repetirSenhaController.text.trim();

    if (nome.isEmpty || sobrenome.isEmpty || rg.isEmpty || email.isEmpty || senha.isEmpty || repetirSenha.isEmpty || batismo == null) {
      _mostrarErro("Preencha todos os campos obrigatórios.");
      return;
    }

    if (senha != repetirSenha) {
      _mostrarErro("As senhas não coincidem.");
      return;
    }

    if (senha.length < 6) {
      _mostrarErro("A senha deve ter pelo menos 6 caracteres.");
      return;
    }

    setState(() => salvando = true);

    try {
      await FirebaseFirestore.instance.collection('usuarios').add({
        'nome': nome,
        'sobrenome': sobrenome,
        'nome_lower': nome.toLowerCase(),
        'sobrenome_lower': sobrenome.toLowerCase(),
        'rg': rg,
        'email': email,
        'senha': senha,
        'batismo': batismo,
        'imagemBase64': widget.imagemBase64,
        'tipo': 'membro',
        'igrejaId': widget.idIgreja,
        'nome_igreja': widget.nomeIgreja,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cadastro realizado com sucesso!')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
      );
    } catch (e) {
      _mostrarErro("Erro ao salvar no Firestore: $e");
    }

    setState(() => salvando = false);
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    sobrenomeController.dispose();
    rgController.dispose();
    emailController.dispose();
    senhaController.dispose();
    repetirSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finalizar Cadastro"),
        backgroundColor: Colors.purple.shade100,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Igreja selecionada:", style: Theme.of(context).textTheme.bodyMedium),
              Text(widget.nomeIgreja, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text("Foto selecionada:"),
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 60,
                backgroundImage: MemoryImage(
                  base64Decode(widget.imagemBase64),
                ),
              ),
              const SizedBox(height: 24),
              CamposCadastroMembro(
                nomeController: nomeController,
                sobrenomeController: sobrenomeController,
                rgController: rgController,
                emailController: emailController,
                senhaController: senhaController,
                repetirSenhaController: repetirSenhaController,
                batismo: batismo,
                onBatismoSelecionado: (value) {
                  setState(() {
                    batismo = value;
                  });
                },
                onSalvar: salvarCadastro,
              ),
              const SizedBox(height: 20),
              if (salvando) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
