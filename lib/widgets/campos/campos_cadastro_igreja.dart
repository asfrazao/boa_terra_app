import 'package:flutter/material.dart';
import '../../models/igreja_model.dart';
import '../../services/igreja_service.dart';

enum TipoExibicaoIgreja {
  dropdownForm,
  dropdownSimples,
  listaAdmin,
}

class IgrejaCampos extends StatelessWidget {
  final TipoExibicaoIgreja tipo;
  final String? valorSelecionado;
  final Function(String?)? onChanged;
  final void Function(IgrejaModel)? onEditar;
  final void Function(IgrejaModel)? onExcluir;

  const IgrejaCampos({
    super.key,
    required this.tipo,
    this.valorSelecionado,
    this.onChanged,
    this.onEditar,
    this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<IgrejaModel>>(
      future: IgrejaService().listarTodas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar igrejas.'));
        }

        final igrejas = snapshot.data ?? [];

        switch (tipo) {
          case TipoExibicaoIgreja.dropdownForm:
            return DropdownButtonFormField<String>(
              value: valorSelecionado,
              onChanged: onChanged,
              decoration: const InputDecoration(
                labelText: 'Selecione a Igreja',
                border: OutlineInputBorder(),
              ),
              items: igrejas.map((i) => DropdownMenuItem(
                value: i.id,
                child: Text(i.denominacao),
              )).toList(),
            );

          case TipoExibicaoIgreja.dropdownSimples:
            return DropdownButton<String>(
              value: valorSelecionado,
              onChanged: onChanged,
              items: igrejas.map((i) => DropdownMenuItem(
                value: i.id,
                child: Text(i.denominacao),
              )).toList(),
            );

          case TipoExibicaoIgreja.listaAdmin:
            return ListView.separated(
              shrinkWrap: true,
              itemCount: igrejas.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final igreja = igrejas[index];
                return ListTile(
                  title: Text(igreja.denominacao),
                  subtitle: Text(igreja.cidade),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => onEditar?.call(igreja),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onExcluir?.call(igreja),
                      ),
                    ],
                  ),
                );
              },
            );
        }
      },
    );
  }
}
