import 'package:flutter/material.dart';
import 'campo_senha.dart';

class CamposCadastroMembro extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController sobrenomeController;
  final TextEditingController rgController;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final TextEditingController repetirSenhaController;

  final String? batismo;
  final Function(String?) onBatismoSelecionado;

  final String? grupoSelecionado;
  final List<String> funcoesSelecionadas;
  final void Function(String) onGrupoSelecionado;
  final void Function(String, bool) onFuncoesSelecionadas;

  final VoidCallback? onSalvar;

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
    required this.grupoSelecionado,
    required this.funcoesSelecionadas,
    required this.onGrupoSelecionado,
    required this.onFuncoesSelecionadas,
    this.onSalvar,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<String>> funcoesPorGrupo = {
      'Grupo das irmãs': ['Lider', 'Regência', 'Consagração', 'Louvor', 'Nenhum'],
      'Grupo dos jovens': ['Lider', 'Regência', 'Louvor', 'Nenhum'],
      'Grupo dos adolescentes': ['Lider', 'Regência', 'Louvor', 'Nenhum'],
      'Grupo das crianças': ['Lider', 'Regência', 'Louvor', 'Nenhum'],
    };

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
        DropdownButtonFormField<String>(
          value: grupoSelecionado,
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
            if (grupo != null) onGrupoSelecionado(grupo);
          },
        ),
        const SizedBox(height: 12),
        if (grupoSelecionado != null && grupoSelecionado != 'Nenhum')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const Text('Funções no grupo:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...funcoesPorGrupo[grupoSelecionado]!.map((funcao) {
                return CheckboxListTile(
                  title: Text(funcao),
                  value: funcoesSelecionadas.contains(funcao),
                  onChanged: (checked) {
                    onFuncoesSelecionadas(funcao, checked ?? false);
                  },
                );
              }).toList(),
            ],
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
          label: const Text("Salvar Cadastro"),
        ),
      ],
    );
  }
}
