import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/dashboard_membro_screen.dart';
import '../screens/dashboard_obreiro_screen.dart';
import '../screens/dashboard_pastor_screen.dart';

class LoginController {
  Future<Widget?> realizarLogin({
    required String nome,
    required String sobrenome,
    required String senha,
    required Function(String) onError,
  }) async {
    try {
      final nomeLower = nome.trim().toLowerCase();
      final sobrenomeLower = sobrenome.trim().toLowerCase();
      final partes = sobrenomeLower.split(' ');
      final ultimoSobrenome = partes.isNotEmpty ? partes.last : sobrenomeLower;

      // 🔹 Tenta primeiro com o sobrenome completo (como pode estar salvo no Firestore)
      final snapshotCompleto = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('nome_lower', isEqualTo: nomeLower)
          .where('sobrenome_lower', isEqualTo: sobrenomeLower)
          .get();

      // 🔹 Se não encontrar, tenta com o último sobrenome (fallback)
      final snapshotAlternativo = snapshotCompleto.docs.isEmpty
          ? await FirebaseFirestore.instance
          .collection('usuarios')
          .where('nome_lower', isEqualTo: nomeLower)
          .where('sobrenome_lower', isEqualTo: ultimoSobrenome)
          .get()
          : snapshotCompleto;

      if (snapshotAlternativo.docs.isEmpty) {
        onError("Nome ou senha inválidos.");
        return null;
      }

      final doc = snapshotAlternativo.docs.first;
      final dados = doc.data();
      final userId = doc.id;

      if (dados['senha'] != senha) {
        onError("Nome ou senha inválidos.");
        return null;
      }

      final nomeIgreja = dados['nome_igreja'] ?? dados['igrejaNome'] ?? 'Igreja não definida';
      final igrejaId = dados['igrejaId'] ?? '';
      final tipo = (dados['tipo'] ?? '').toString().toLowerCase();

      if (tipo == 'membro') {
        return DashboardMembroScreen(
          nome: dados['nome'],
          igrejaNome: nomeIgreja,
          igrejaId: igrejaId,
          userId: userId,
        );
      } else if (tipo == 'obreiro') {
        return DashboardObreiroScreen(
          userId: userId,
          nome: dados['nome'],
          igrejaNome: nomeIgreja,
          igrejaId: igrejaId,
        );
      } else if (tipo == 'pastor') {
        return DashboardPastorScreen(
          nome: dados['nome'],
          igrejaNome: nomeIgreja,
          igrejaId: igrejaId,
          userId: userId,
        );
      } else {
        onError("Tipo de usuário inválido.");
        return null;
      }
    } catch (e) {
      onError("Erro ao tentar login: $e");
      return null;
    }
  }
}
