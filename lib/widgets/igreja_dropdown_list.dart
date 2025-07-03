import 'package:flutter/material.dart';
import '../models/igreja_model.dart';

class IgrejaDropdownList extends StatelessWidget {
  final List<IgrejaModel> igrejas;
  final void Function(IgrejaModel) onEditar;
  final void Function(String id) onExcluir;

  const IgrejaDropdownList({
    super.key,
    required this.igrejas,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    if (igrejas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Igrejas já cadastradas:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...igrejas.map((igreja) {
          return ListTile(
            title: Text(igreja.denominacao),
            subtitle: Text('${igreja.cidade} - ${igreja.estado}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => onEditar(igreja),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmarExclusao(context, igreja),
                ),
              ],
            ),
          );
        }),
        const Divider(),
      ],
    );
  }

  void _confirmarExclusao(BuildContext context, IgrejaModel igreja) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar exclusão"),
        content: Text("Deseja excluir a igreja '${igreja.denominacao}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Excluir")),
        ],
      ),
    );

    if (confirmar == true) {
      onExcluir(igreja.id!);
    }
  }
}
