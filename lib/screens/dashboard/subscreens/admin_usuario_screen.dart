import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'perfil_usuario_screen.dart';

enum TipoFiltroUsuario { todos, pastores, obreiros, membros }

class AdminUsuariosScreen extends StatefulWidget {
  final String convite;
  final String userId;

  const AdminUsuariosScreen({
    super.key,
    required this.convite,
    required this.userId,
  });

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  TipoFiltroUsuario filtro = TipoFiltroUsuario.todos;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> usuarios = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    setState(() => carregando = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('convite', isEqualTo: widget.convite)
        .get();

    setState(() {
      usuarios = snapshot.docs
          .where((doc) => doc.id != widget.userId)
          .toList();
      carregando = false;
    });
  }

  void _atualizarFiltro(TipoFiltroUsuario novo) {
    setState(() {
      filtro = novo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuariosFiltrados = usuarios.where((doc) {
      final tipo = (doc.data()['tipo'] ?? '').toString().toLowerCase();
      switch (filtro) {
        case TipoFiltroUsuario.todos:
          return true;
        case TipoFiltroUsuario.pastores:
          return tipo == 'pastor';
        case TipoFiltroUsuario.obreiros:
          return tipo == 'obreiro';
        case TipoFiltroUsuario.membros:
          return tipo == 'membro';
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Obreiros e Membros'),
        backgroundColor: Colors.deepPurple.shade50,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFiltro("Todos", TipoFiltroUsuario.todos),
                _buildFiltro("Pastores", TipoFiltroUsuario.pastores),
                _buildFiltro("Obreiros", TipoFiltroUsuario.obreiros),
                _buildFiltro("Membros", TipoFiltroUsuario.membros),
              ],
            ),
            const SizedBox(height: 16),
            if (carregando)
              const Center(child: CircularProgressIndicator()),
            if (!carregando && usuariosFiltrados.isEmpty)
              const Center(child: Text('Nenhum usuário encontrado.')),
            if (!carregando && usuariosFiltrados.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: usuariosFiltrados.length,
                  itemBuilder: (context, index) {
                    final user = usuariosFiltrados[index].data();
                    final nome = user['nome'] ?? '';
                    final sobrenome = user['sobrenome'] ?? '';
                    final tipo = user['tipo'] ?? '';
                    final fotoBase64 = (user['imagem'] ?? '') as String;
                    final fotoValida = fotoBase64.isNotEmpty && !fotoBase64.contains('data:image');
                    final fotoBytes = fotoValida ? base64Decode(fotoBase64) : null;

                    return ListTile(
                      leading: fotoBytes != null
                          ? CircleAvatar(backgroundImage: MemoryImage(fotoBytes))
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text("$nome $sobrenome"),
                      subtitle: Text(tipo),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PerfilUsuarioScreen(
                              dadosUsuario: usuariosFiltrados[index].data(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltro(String label, TipoFiltroUsuario tipoFiltro) {
    final ativo = filtro == tipoFiltro;
    return ChoiceChip(
      label: Text(label),
      selected: ativo,
      onSelected: (_) => _atualizarFiltro(tipoFiltro),
    );
  }
}
