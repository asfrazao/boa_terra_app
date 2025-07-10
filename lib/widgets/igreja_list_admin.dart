// lib/widgets/igreja_list_admin.dart

import 'package:flutter/material.dart';
import '../models/igreja_model.dart';

class IgrejaListAdmin extends StatelessWidget {
  final List<IgrejaModel> igrejas;
  final void Function(IgrejaModel) onEditar;
  final void Function(String convite) onExcluir; // ⬅️ agora usamos o convite

  const IgrejaListAdmin({
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
        title: const Text("Excluir Igreja"),
        content: const Text(
          "Tem certeza que deseja excluir esta Igreja?\n"
              "Todos os Pastores/Obreiros/Membros serão excluídos também.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      if (igreja.convite != null && igreja.convite!.isNotEmpty) {
        onExcluir(igreja.convite!); // ✅ exclui tudo pelo convite
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Convite da igreja não encontrado.')),
        );
      }
    }
  }
}
