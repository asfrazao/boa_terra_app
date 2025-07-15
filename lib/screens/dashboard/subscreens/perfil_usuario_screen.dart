import 'dart:convert';
import 'package:flutter/material.dart';

class PerfilUsuarioScreen extends StatelessWidget {
  final Map<String, dynamic> dadosUsuario;

  const PerfilUsuarioScreen({super.key, required this.dadosUsuario});

  @override
  Widget build(BuildContext context) {
    final nome = dadosUsuario['nome'] ?? '';
    final sobrenome = dadosUsuario['sobrenome'] ?? '';
    final batismo = dadosUsuario['batismo'] ?? '';
    final tipo = (dadosUsuario['tipo'] ?? '').toString().toLowerCase();
    final grupo = dadosUsuario['grupo'] ?? '';
    final cargo = dadosUsuario['cargo'] ?? '';
    final funcoesSelecionadas = dadosUsuario['funcoesSelecionadas'] ?? {};

    final participaLouvor = dadosUsuario['Louvor'] == true;
    final participaConsagracao = dadosUsuario['Consagracao'] == true;
    final participaRegencia = dadosUsuario['Regencia'] == true;

    final fotoBase64 = (dadosUsuario['imagem'] ?? '') as String;
    final fotoValida = fotoBase64.isNotEmpty && !fotoBase64.contains('data:image');
    final fotoBytes = fotoValida ? base64Decode(fotoBase64) : null;

    final funcoes = (funcoesSelecionadas is Map<String, dynamic>)
        ? funcoesSelecionadas.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .join(', ')
        : '';

    // Novo título dinâmico conforme tipo e atributos
    String tituloExibicao;
    if (tipo == 'pastor') {
      final isCoPastor = dadosUsuario['Co-Pastor'] == true;
      final isAuxiliar = dadosUsuario['Auxiliar'] == true;

      if (isCoPastor) {
        tituloExibicao = "Co-Pastor da nossa Igreja";
      } else if (isAuxiliar) {
        tituloExibicao = "Pastor (auxiliar) da nossa Igreja";
      } else {
        tituloExibicao = "Pastor da nossa Igreja";
      }
    } else {
      tituloExibicao = "${tipo[0].toUpperCase()}${tipo.substring(1)} da nossa Igreja";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        backgroundColor: Colors.purple.shade50,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (fotoBytes != null)
                CircleAvatar(radius: 48, backgroundImage: MemoryImage(fotoBytes))
              else
                const CircleAvatar(radius: 48, child: Icon(Icons.person)),
              const SizedBox(height: 16),

              // Nome
              Text("$nome $sobrenome", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Tipo ajustado dinamicamente
              Text(tituloExibicao, style: const TextStyle(fontSize: 16)),

              // Batismo visível apenas se não for pastor
              if (batismo != '' && tipo != 'pastor')
                Text("Batizado: $batismo", style: const TextStyle(fontSize: 16)),

              if (grupo != '')
                Text("Grupo: $grupo", style: const TextStyle(fontSize: 16)),

              if (cargo != '')
                Text("Cargo: $cargo", style: const TextStyle(fontSize: 16)),

              if (funcoes != '')
                Text("Funções: $funcoes", style: const TextStyle(fontSize: 16)),

              if (participaLouvor)
                const Text("Participa do Louvor", style: TextStyle(fontSize: 16)),

              if (participaConsagracao)
                const Text("Participa da Consagração", style: TextStyle(fontSize: 16)),

              if (participaRegencia)
                const Text("Participa da Regência", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
