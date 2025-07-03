import 'package:flutter/material.dart';

class DashboardPastorScreen extends StatelessWidget {
  final String nome;
  final String igrejaNome;

  const DashboardPastorScreen({
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
        title: const Text("Dashboard do Pastor"),
        backgroundColor: Colors.purple.shade100,
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

            _botaoDash("Enviar Recados", Icons.message, () {
              // TODO: Tela para envio de recados aos membros e obreiros
            }),
            _botaoDash("Gerenciar Eventos", Icons.event_available, () {
              // TODO: Tela de criação e gestão de eventos
            }),
            _botaoDash("Visualizar Pedidos de Oração", Icons.favorite, () {
              // TODO: Tela para visualizar e orar pelos pedidos
            }),
            _botaoDash("Administrar Obreiros e Membros", Icons.groups, () {
              // TODO: Tela de administração da igreja
            }),
          ],
        ),
      ),
    );
  }
}
