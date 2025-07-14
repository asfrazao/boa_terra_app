import 'dart:convert';
import 'package:flutter/material.dart';
import '../../controllers/cadastro_pastor_controller.dart';
import '../campo_senha.dart';

class CamposCadastroPastor extends StatefulWidget {
  final CadastroPastorController controller;
  final VoidCallback? onSalvar;

  const CamposCadastroPastor({
    super.key,
    required this.controller,
    this.onSalvar,
  });

  @override
  State<CamposCadastroPastor> createState() => _CamposCadastroPastorState();
}

class _CamposCadastroPastorState extends State<CamposCadastroPastor> {
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
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
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        return Column(
          children: [
            const Text("Funções específicas", style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text("Pastor Oficial"),
              value: widget.controller.funcoesSelecionadas['Pastor Oficial'],
              onChanged: (value) {
                widget.controller.alternarFuncao('Pastor Oficial', value ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text("Co-Pastor"),
              value: widget.controller.funcoesSelecionadas['Co-Pastor'],
              onChanged: (value) {
                widget.controller.alternarFuncao('Co-Pastor', value ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text("Auxiliar"),
              value: widget.controller.funcoesSelecionadas['Auxiliar'],
              onChanged: (value) {
                widget.controller.alternarFuncao('Auxiliar', value ?? false);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.controller.nomeController,
              decoration: const InputDecoration(labelText: "Primeiro Nome"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.controller.sobrenomeController,
              decoration: const InputDecoration(labelText: "Último Nome"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.controller.rgController,
              focusNode: _focusRG,
              decoration: const InputDecoration(labelText: "RG"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.controller.emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            CampoSenha(
              senhaController: widget.controller.senhaController,
              repetirSenhaController: widget.controller.repetirSenhaController,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onSalvar,
              icon: const Icon(Icons.save),
              label: const Text("Salvar Cadastro"),
            ),
          ],
        );
      },
    );
  }
}
