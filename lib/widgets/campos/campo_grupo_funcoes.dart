import 'package:flutter/material.dart';

class CampoGrupoFuncoes extends StatefulWidget {
  final String? grupoSelecionado;
  final Map<String, bool> funcoesSelecionadas;
  final void Function(String?) onGrupoSelecionado;
  final void Function(Map<String, bool>) onFuncoesAlteradas;

  const CampoGrupoFuncoes({
    super.key,
    required this.grupoSelecionado,
    required this.funcoesSelecionadas,
    required this.onGrupoSelecionado,
    required this.onFuncoesAlteradas,
  });

  @override
  State<CampoGrupoFuncoes> createState() => _CampoGrupoFuncoesState();
}

class _CampoGrupoFuncoesState extends State<CampoGrupoFuncoes> {
  final Map<String, List<String>> funcoesPorGrupo = {
    'Grupo das irmãs': ['Lider', 'Regência', 'Consagração', 'Louvor', 'Nenhum'],
    'Grupo dos jovens': ['Lider', 'Regência', 'Louvor', 'Nenhum'],
    'Grupo dos adolescentes': ['Lider', 'Regência', 'Louvor', 'Nenhum'],
    'Grupo das crianças': ['Lider', 'Regência', 'Louvor', 'Nenhum'],
  };

  @override
  Widget build(BuildContext context) {
    final grupo = widget.grupoSelecionado;
    final opcoes = grupo != null && grupo != 'Nenhum' ? funcoesPorGrupo[grupo] ?? [] : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: grupo,
          decoration: const InputDecoration(labelText: "A qual grupo o irmão(ã) pertence?"),
          items: const [
            DropdownMenuItem(value: 'Grupo das irmãs', child: Text('Grupo das irmãs')),
            DropdownMenuItem(value: 'Grupo dos jovens', child: Text('Grupo dos jovens')),
            DropdownMenuItem(value: 'Grupo dos adolescentes', child: Text('Grupo dos adolescentes')),
            DropdownMenuItem(value: 'Grupo das crianças', child: Text('Grupo das crianças')),
            DropdownMenuItem(value: 'Nenhum', child: Text('Nenhum')),
          ],
          onChanged: (g) {
            widget.onGrupoSelecionado(g);
            widget.onFuncoesAlteradas({});
          },
        ),
        const SizedBox(height: 12),
        if (grupo != null && grupo != 'Nenhum' && opcoes.isNotEmpty) ...[
          const Divider(),
          const Text('Funções no grupo:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...opcoes.map((opcao) {
            return CheckboxListTile(
              title: Text(opcao),
              dense: true,
              value: widget.funcoesSelecionadas[opcao] ?? false,
              onChanged: (val) {
                final atual = Map<String, bool>.from(widget.funcoesSelecionadas);
                if (opcao == 'Nenhum') {
                  atual.clear();
                  if (val == true) atual['Nenhum'] = true;
                } else {
                  atual[opcao] = val ?? false;
                  if (atual['Nenhum'] == true) atual['Nenhum'] = false;
                }
                widget.onFuncoesAlteradas(atual);
              },
            );
          }),
        ],
      ],
    );
  }
}
