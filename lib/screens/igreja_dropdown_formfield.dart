// lib/widgets/igreja_dropdown_formfield.dart

import 'package:flutter/material.dart';
import '../models/igreja_model.dart';

class IgrejaDropdownFormField extends StatelessWidget {
  final List<IgrejaModel> igrejas;
  final IgrejaModel? igrejaSelecionada;
  final void Function(IgrejaModel?) onSelecionar;

  const IgrejaDropdownFormField({
    super.key,
    required this.igrejas,
    required this.igrejaSelecionada,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<IgrejaModel>(
      value: igrejaSelecionada,
      items: igrejas.map((igreja) {
        return DropdownMenuItem<IgrejaModel>(
          value: igreja,
          child: Text(igreja.denominacao),
        );
      }).toList(),
      onChanged: onSelecionar,
      decoration: const InputDecoration(
        labelText: 'Selecione a igreja',
        border: OutlineInputBorder(),
      ),
    );
  }
}
