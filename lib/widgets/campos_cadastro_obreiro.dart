import 'package:flutter/material.dart';
import '../controllers/cadastro_obreiro_controller.dart';
import 'campo_senha.dart';

class CamposCadastroObreiro extends StatefulWidget {
  final CadastroObreiroController controller;

  const CamposCadastroObreiro({
    super.key,
    required this.controller,
  });

  @override
  State<CamposCadastroObreiro> createState() => _CamposCadastroObreiroState();
}

class _CamposCadastroObreiroState extends State<CamposCadastroObreiro> {
  final FocusNode _focusRG = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusRG.addListener(() {
      if (_focusRG.hasFocus) {
        final sobrenome = widget.controller.sobrenomeController.text.trim();
        if (sobrenome.split(' ').length > 1) {
          widget.controller.sobrenomeController.clear();

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Atenção"),
              content: const Text("Use apenas o último sobrenome."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _focusRG.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.nomeController,
          decoration: const InputDecoration(labelText: 'Primeiro Nome'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.sobrenomeController,
          decoration: const InputDecoration(labelText: 'Último Nome'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          focusNode: _focusRG,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.rgController,
          decoration: const InputDecoration(labelText: 'RG'),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: controller.cargoSelecionado,
          decoration: const InputDecoration(labelText: 'Qual o trabalho na igreja?'),
          items: const [
            DropdownMenuItem(value: 'Cooperador', child: Text('Cooperador')),
            DropdownMenuItem(value: 'Obreiro', child: Text('Obreiro')),
            DropdownMenuItem(value: 'Diácono', child: Text('Diácono')),
            DropdownMenuItem(value: 'Presbítero', child: Text('Presbítero')),
            DropdownMenuItem(value: 'Evangelista', child: Text('Evangelista')),
            DropdownMenuItem(value: 'Capelania', child: Text('Capelania')),
          ],
          onChanged: (value) {
            setState(() {
              controller.cargoSelecionado = value;
            });
          },
        ),
        const SizedBox(height: 12),
        CampoSenha(
          senhaController: controller.senhaController,
          repetirSenhaController: controller.repetirSenhaController,
        ),
      ],
    );
  }
}
