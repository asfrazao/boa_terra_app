import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastroUsuarioService {
  /// Salva o cadastro (novo ou edição) sem retorno de ID
  static Future<bool> salvarCadastro({
    required BuildContext context,
    String? userId, // null para novo cadastro
    required String tipo,
    required String idIgreja,
    required String nomeIgreja,
    required String adminSetor,
    required String imagemBase64,
    required String nome,
    required String sobrenome,
    required String rg,
    required String email,
    required String senha,
    required String repetirSenha,
    required String convite,
    required String? batismo,
    required String? grupo,
    required Map<String, bool> extrasSelecionados,
  }) async {
    if (userId == null && senha.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ A senha é obrigatória')),
      );
      return false;
    }

    if (senha != repetirSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ As senhas não coincidem')),
      );
      return false;
    }

    final dados = <String, dynamic>{
      'tipo': tipo,
      'igrejaId': idIgreja,
      'igrejaNome': nomeIgreja,
      'setorAdmin': adminSetor,
      'imagem': imagemBase64,
      'nome': nome,
      'sobrenome': sobrenome,
      'nome_lower': nome.toLowerCase(),
      'sobrenome_lower': sobrenome.toLowerCase(),
      'rg': rg,
      'email': email,
      'batismo': batismo ?? 'Não informado',
      'convite': convite,
      'dataAtualizacao': FieldValue.serverTimestamp(),
    };

    if (grupo != null && grupo.isNotEmpty) {
      dados['grupo'] = grupo;
    }

    for (final entry in extrasSelecionados.entries) {
      dados[entry.key] = entry.value;
    }

    if (senha.trim().isNotEmpty) {
      dados['senha'] = senha;
    }

    try {
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .update(dados);
      } else {
        await FirebaseFirestore.instance.collection('usuarios').add({
          ...dados,
          'senha': senha,
          'dataCadastro': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar cadastro: $e')),
      );
      return false;
    }
  }

  /// Nova função: salva e retorna o ID do documento criado
  static Future<String?> salvarCadastroERetornarId({
    required BuildContext context,
    required String tipo,
    required String idIgreja,
    required String nomeIgreja,
    required String adminSetor,
    required String imagemBase64,
    required String nome,
    required String sobrenome,
    required String rg,
    required String email,
    required String senha,
    required String repetirSenha,
    required String convite,
    required String? batismo,
    required String? grupo,
    required Map<String, bool> extrasSelecionados,
  }) async {
    if (senha.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ A senha é obrigatória')),
      );
      return null;
    }

    if (senha != repetirSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ As senhas não coincidem')),
      );
      return null;
    }

    final dados = <String, dynamic>{
      'tipo': tipo,
      'igrejaId': idIgreja,
      'igrejaNome': nomeIgreja,
      'setorAdmin': adminSetor,
      'imagem': imagemBase64,
      'nome': nome,
      'sobrenome': sobrenome,
      'nome_lower': nome.toLowerCase(),
      'sobrenome_lower': sobrenome.toLowerCase(),
      'rg': rg,
      'email': email,
      'batismo': batismo ?? 'Não informado',
      'convite': convite,
      'dataCadastro': FieldValue.serverTimestamp(),
      'dataAtualizacao': FieldValue.serverTimestamp(),
      'senha': senha,
    };

    if (grupo != null && grupo.isNotEmpty) {
      dados['grupo'] = grupo;
    }

    for (final entry in extrasSelecionados.entries) {
      dados[entry.key] = entry.value;
    }

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('usuarios')
          .add(dados);

      return docRef.id;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar cadastro: $e')),
      );
      return null;
    }
  }
}
