import 'package:flutter/material.dart';
import '../campo_senha.dart';

class CamposCadastroUsuario extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController sobrenomeController;
  final TextEditingController rgController;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final TextEditingController repetirSenhaController;

  final String? batismo;
  final Function(String?)? onBatismoSelecionado;

  final bool exibirBatismo;
  final VoidCallback? onSalvar;

  const CamposCadastroUsuario({
    super.key,
    required this.nomeController,
    required this.sobrenomeController,
    required this.rgController,
    required this.emailController,
    required this.senhaController,
    required this.repetirSenhaController,
    this.batismo,
    this.onBatismoSelecionado,
    this.exibirBatismo = true,
    this.onSalvar,
  });

  void _validarSobrenome(BuildContext context) {
    final sobrenome = sobrenomeController.text.trim();
    if (sobrenome.split(' ').length > 1) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Atenção"),
          content: const Text("Use apenas o último sobrenome (sem espaços)."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      sobrenomeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nomeController,
          decoration: const InputDecoration(labelText: "Primeiro Nome"),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: sobrenomeController,
          decoration: const InputDecoration(labelText: "Último Nome"),
          onChanged: (_) => _validarSobrenome(context),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: rgController,
          decoration: const InputDecoration(labelText: "RG"),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: "Email"),
        ),
        const SizedBox(height: 12),

        if (exibirBatismo)
          DropdownButtonFormField<String>(
            value: batismo,
            decoration: const InputDecoration(labelText: "Batizado?"),
            items: const [
              DropdownMenuItem(value: "Sim", child: Text("Sim")),
              DropdownMenuItem(value: "Não", child: Text("Não")),
            ],
            onChanged: onBatismoSelecionado,
          ),

        const SizedBox(height: 12),
        CampoSenha(
          senhaController: senhaController,
          repetirSenhaController: repetirSenhaController,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onSalvar,
          icon: const Icon(Icons.save),
          label: const Text("Salvar"),
        ),
      ],
    );
  }
}
