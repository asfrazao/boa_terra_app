import 'package:flutter/material.dart';

class DashboardObreiroScreen extends StatelessWidget {
  final String nome;
  final String igrejaNome;

  const DashboardObreiroScreen({
    super.key,
    required this.nome,
    required this.igrejaNome,
  });

  Widget _botaoDash(String titulo, IconData icone, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icone, size: 32),
        title: Text(titulo),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard do Obreiro"),
        backgroundColor: Colors.deepPurple.shade100,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Olá $nome, bem-vindo ao BOA TERRA.", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(igrejaNome, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),

            _botaoDash("Organizar Cultos", Icons.schedule, () {
              // TODO: Implementar tela de organização de cultos
            }),
            _botaoDash("Ler Recados do Pastor", Icons.mail, () {
              // TODO: Implementar visualização de recados
            }),
            _botaoDash("Ver Pedidos de Oração", Icons.favorite_border, () {
              // TODO: Implementar leitura dos pedidos de oração
            }),
            _botaoDash("Eventos e Programações", Icons.event, () {
              // TODO: Implementar listagem de eventos
            }),
          ],
        ),
      ),
    );
  }
}
