import 'package:flutter/material.dart';

class CamposCadastroMembro extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController sobrenomeController;
  final TextEditingController rgController;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final TextEditingController repetirSenhaController;
  final String? batismo; // 'Sim' ou 'Não'
  final void Function(String? value) onBatismoSelecionado;
  final VoidCallback onSalvar;

  const CamposCadastroMembro({
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
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildCampo(nomeController, "Primeiro Nome"),
          _buildCampo(sobrenomeController, "Último Nome"),
          _buildCampo(rgController, "RG"),
          _buildCampo(emailController, "E-mail", tipo: TextInputType.emailAddress, validador: _validarEmail),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Já é Batizado(a)?", style: TextStyle(fontSize: 16)),
          ),
          Row(
            children: [
              Radio<String>(
                value: 'Sim',
                groupValue: batismo,
                onChanged: onBatismoSelecionado,
              ),
              const Text("Sim"),
              Radio<String>(
                value: 'Não',
                groupValue: batismo,
                onChanged: onBatismoSelecionado,
              ),
              const Text("Não"),
            ],
          ),
          if (batismo == null)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Campo obrigatório", style: TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 16),
          _buildCampo(senhaController, "Senha (mín. 6 dígitos)", obscure: true),
          _buildCampo(repetirSenhaController, "Repetir Senha", obscure: true, validador: (value) {
            if (value != senhaController.text) return 'As senhas não coincidem';
            return null;
          }),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate() && batismo != null) {
                onSalvar();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⚠️ Preencha todos os campos obrigatórios')),
                );
              }
            },
            child: const Text("Finalizar Cadastro"),
          ),
        ],
      ),
    );
  }

  Widget _buildCampo(TextEditingController controller, String label,
      {bool obscure = false, TextInputType tipo = TextInputType.text, String? Function(String?)? validador}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validador ?? (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo obrigatório';
          }
          if (label.contains("Senha") && value.length < 6) {
            return 'Senha deve ter ao menos 6 dígitos';
          }
          return null;
        },
      ),
    );
  }

  String? _validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    final emailValido = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$');
    return emailValido.hasMatch(value) ? null : 'E-mail inválido';
  }
}
