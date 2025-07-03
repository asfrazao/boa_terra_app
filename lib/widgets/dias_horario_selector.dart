import 'package:flutter/material.dart';

class DiasHorarioSelector extends StatelessWidget {
  final Map<String, bool> diasSelecionados;
  final Map<String, List<TimeOfDay>> horariosCulto;
  final void Function(String dia, TimeOfDay novoHorario, int index)? onEditarHorario;
  final void Function(String dia, int index)? onRemoverHorario;
  final void Function(String dia)? onAdicionarHorario;
  final void Function(String dia, bool selecionado)? onSelecionarDia;

  const DiasHorarioSelector({
    super.key,
    required this.diasSelecionados,
    required this.horariosCulto,
    this.onEditarHorario,
    this.onRemoverHorario,
    this.onAdicionarHorario,
    this.onSelecionarDia,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: diasSelecionados.keys.map((dia) {
        final selecionado = diasSelecionados[dia]!;
        final horarios = horariosCulto[dia]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: Text(dia),
              value: selecionado,
              onChanged: (valor) {
                if (onSelecionarDia != null) {
                  onSelecionarDia!(dia, valor ?? false);
                }
              },
            ),
            if (selecionado)
              ...horarios.asMap().entries.map((entry) {
                final index = entry.key;
                final hora = entry.value;
                return ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text('${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final novo = await showTimePicker(
                            context: context,
                            initialTime: hora,
                          );
                          if (novo != null && onEditarHorario != null) {
                            onEditarHorario!(dia, novo, index);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (onRemoverHorario != null) {
                            onRemoverHorario!(dia, index);
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
            if (selecionado)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Adicionar horário"),
                  onPressed: () {
                    if (onAdicionarHorario != null) {
                      onAdicionarHorario!(dia);
                    }
                  },
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}
