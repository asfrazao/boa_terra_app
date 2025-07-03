import 'package:flutter/material.dart';

class CamposCadastroUsuario extends StatefulWidget {
  final TextEditingController nomeController;
  final TextEditingController sobrenomeController;
  final TextEditingController rgController;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final TextEditingController repetirSenhaController;
  final String? batismo;
  final Function(String?) onBatismoSelecionado;
  final VoidCallback? onSalvar;

  const CamposCadastroUsuario({
    super.key,
    required this.nomeController,
    required this.sobrenomeController,
    required this.rgController,
    required this.emailController,
    required this.senhaController,
    required this.repetirSenhaController,
    required this.batismo,
    required this.onBatismoSelecionado,
    required this.onSalvar,
  });

  @override
  State<CamposCadastroUsuario> createState() => _CamposCadastroUsuarioState();
}

class _CamposCadastroUsuarioState extends State<CamposCadastroUsuario> {
  bool _senhaVisivel = false;
  bool _repetirSenhaVisivel = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.nomeController,
          decoration: const InputDecoration(labelText: "Primeiro Nome"),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.sobrenomeController,
          decoration: const InputDecoration(labelText: "Último Sobrenome"),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.rgController,
          decoration: const InputDecoration(labelText: "RG"),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.emailController,
          decoration: const InputDecoration(labelText: "Email"),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: widget.batismo,
          decoration: const InputDecoration(labelText: "Batizado?"),
          items: const [
            DropdownMenuItem(value: "Sim", child: Text("Sim")),
            DropdownMenuItem(value: "Não", child: Text("Não")),
          ],
          onChanged: widget.onBatismoSelecionado,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.senhaController,
          obscureText: !_senhaVisivel,
          decoration: InputDecoration(
            labelText: "Senha",
            suffixIcon: IconButton(
              icon: Icon(_senhaVisivel ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() => _senhaVisivel = !_senhaVisivel);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.repetirSenhaController,
          obscureText: !_repetirSenhaVisivel,
          decoration: InputDecoration(
            labelText: "Repetir Senha",
            suffixIcon: IconButton(
              icon: Icon(_repetirSenhaVisivel ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() => _repetirSenhaVisivel = !_repetirSenhaVisivel);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: widget.onSalvar,
          icon: const Icon(Icons.save),
          label: const Text("Salvar"),
        ),
      ],
    );
  }
}
