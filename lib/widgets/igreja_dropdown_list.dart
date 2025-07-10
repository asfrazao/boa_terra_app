import 'package:flutter/material.dart';

class IgrejaDropdownList extends StatelessWidget {
  final List<Map<String, dynamic>> igrejas;
  final String? igrejaSelecionada;
  final void Function(String) onSelecionar;
  final void Function(String)? onEditar;
  final void Function(String)? onExcluir;

  const IgrejaDropdownList({
    super.key,
    required this.igrejas,
    required this.igrejaSelecionada,
    required this.onSelecionar,
    this.onEditar,
    this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    if (igrejas.isEmpty) return const SizedBox.shrink();

    return DropdownButtonFormField<String>(
      value: igrejaSelecionada,
      decoration: InputDecoration(
        labelText: 'Selecione a Igreja',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: igrejas.map((ig) {
        final nome = ig['denominacao'] ?? 'Sem nome';
        return DropdownMenuItem<String>(
          value: nome,
          child: Text(nome),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onSelecionar(value);
        }
      },
    );
  }
}
