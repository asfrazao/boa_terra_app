import 'package:flutter/material.dart';
import '../campo_senha.dart';
import '../../controllers/cadastro_membro_controller.dart';

class CamposCadastroMembro extends StatefulWidget {
  final CadastroMembroController controller;
  final VoidCallback? onSalvar;

  const CamposCadastroMembro({
    super.key,
    required this.controller,
    this.onSalvar,
  });

  @override
  State<CamposCadastroMembro> createState() => _CamposCadastroMembroState();
}

class _CamposCadastroMembroState extends State<CamposCadastroMembro> {
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
      children: [
        TextFormField(
          controller: controller.nomeController,
          decoration: const InputDecoration(labelText: "Primeiro Nome"),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.sobrenomeController,
          decoration: const InputDecoration(labelText: "Último Nome"),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.rgController,
          focusNode: _focusRG,
          decoration: const InputDecoration(labelText: "RG"),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: "Email"),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const Text('Funções no grupo:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...controller
                  .funcoesPorGrupo[controller.grupoSelecionado]!
                  .map((funcao) {
                return CheckboxListTile(
                  title: Text(funcao),
                  value: controller.funcoesSelecionadas[funcao] ?? false,
                  onChanged: (checked) {
                    setState(() {
                      controller.alternarFuncao(funcao, checked ?? false);
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
          onPressed: widget.onSalvar,
          icon: const Icon(Icons.save),
          label: const Text("Finalizar Cadastro"),
        ),
      ],
    );
  }
}
