import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastroMembroController {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController rgController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController repetirSenhaController = TextEditingController();

  String? batismo; // 'Sim' ou 'Não'
  String? imagemBase64;
  String? idIgreja;

  bool validarCampos() {
    if (nomeController.text.trim().isEmpty ||
        sobrenomeController.text.trim().isEmpty ||
        rgController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        senhaController.text.trim().length < 6 ||
        repetirSenhaController.text != senhaController.text ||
        batismo == null ||
        imagemBase64 == null ||
        idIgreja == null) {
      return false;
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$');
    return emailRegex.hasMatch(emailController.text.trim());
  }

  Future<void> salvarMembro() async {
    final novoMembro = {
      'primeiro_nome': nomeController.text.trim(),
      'ultimo_nome': sobrenomeController.text.trim(),
      'rg': rgController.text.trim(),
      'email': emailController.text.trim(),
      'batismo': batismo,
      'senha': senhaController.text.trim(), // 🚨 em produção, use criptografia!
      'imagem_base64': imagemBase64,
      'igreja_id': idIgreja,
      'dataCadastro': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('membros').add(novoMembro);
  }

  void limpar() {
    nomeController.clear();
    sobrenomeController.clear();
    rgController.clear();
    emailController.clear();
    senhaController.clear();
    repetirSenhaController.clear();
    batismo = null;
    imagemBase64 = null;
    idIgreja = null;
  }
}
