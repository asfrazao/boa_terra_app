import 'package:flutter/material.dart';
import '../models/igreja_model.dart';
import '../services/igreja_service.dart';

class CultosScreen extends StatefulWidget {
  final String igrejaId;

  const CultosScreen({super.key, required this.igrejaId});

  @override
  State<CultosScreen> createState() => _CultosScreenState();
}

class _CultosScreenState extends State<CultosScreen> {
  IgrejaModel? igreja;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarIgreja();
  }

  Future<void> _carregarIgreja() async {
    try {
      final model = await IgrejaService().buscarPorId(widget.igrejaId);
      setState(() {
        igreja = model;
        carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar igreja: $e');
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Informações da Igreja"),
        backgroundColor: Colors.deepPurple.shade100,
        foregroundColor: Colors.black,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : igreja == null
          ? const Center(child: Text("Igreja não encontrada."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${igreja!.denominacao} | ${igreja!.adminSetor ?? ''}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              "${igreja!.endereco}, ${igreja!.numero} - ${igreja!.bairro} - ${igreja!.cidade}, ${igreja!.estado}",
              style: const TextStyle(fontSize: 14),
            ),
            const Divider(height: 24),
            Text("Pastor: ${igreja!.pastorNome} ${igreja!.pastorSobrenome}", style: labelStyle),
            if (igreja!.coPastor != null && igreja!.coPastorSobrenome != null)
              Text("Co-Pastor: ${igreja!.coPastor} ${igreja!.coPastorSobrenome}", style: labelStyle),
            const Divider(height: 24),
            Text("Dias e horários de culto:", style: labelStyle),
            const SizedBox(height: 8),
            ..._listarCultos(igreja!.diasCultos),
          ],
        ),
      ),
    );
  }

  List<Widget> _listarCultos(List<Map<String, String>> cultos) {
    final diasOrdenados = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado'
    ];

    final cultosOrdenados = cultos
        .where((c) => c.containsKey('dia') && c.containsKey('horario'))
        .toList()
      ..sort((a, b) => diasOrdenados.indexOf(a['dia']!).compareTo(diasOrdenados.indexOf(b['dia']!)));

    return cultosOrdenados
        .map((culto) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Text("${culto['dia']}: ${culto['horario']}", style: const TextStyle(fontSize: 14)),
        ],
      ),
    ))
        .toList();
  }
}
