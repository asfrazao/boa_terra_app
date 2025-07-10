import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class ValidadorConvite {
  static const String prefixo = 'BOATERRA';

  /// Gera um código de convite com base no ID da igreja
  static String gerarConvite(String idIgreja) {
    final random = Random.secure();
    const caracteres = 'ABCDEFGHJKMNOPQRSTUVWXYZ0123456789';
    final sufixo = List.generate(3, (_) => caracteres[random.nextInt(caracteres.length)]).join();
    return '$prefixo-$idIgreja-$sufixo';
  }

  /// Gera um convite temporário com ID aleatório de 3 dígitos
  static String gerarConviteTemporario() {
    final random = Random.secure();
    final idAleatorio = (random.nextInt(900) + 100).toString(); // 100–999
    return gerarConvite(idAleatorio);
  }

  /// Valida se o convite informado está no padrão correto
  static bool validar(String convite) {
    final partes = convite.split('-');
    if (partes.length != 3) return false;

    final pfx = partes[0];
    final idIgreja = partes[1];
    final sufixo = partes[2];

    return pfx == prefixo &&
        idIgreja.isNotEmpty &&
        sufixo.length == 3 &&
        RegExp(r'^[A-Z0-9]{3}$').hasMatch(sufixo);
  }

  /// Extrai o ID da igreja a partir do código do convite
  static String? extrairIdIgreja(String convite) {
    if (!validar(convite)) return null;
    return convite.split('-')[1];
  }

  /// Gera e salva automaticamente o convite final no Firestore
  static Future<String> gerarEAtualizarConvite(String idIgreja) async {
    final convite = gerarConvite(idIgreja);
    await FirebaseFirestore.instance.collection('igrejas').doc(idIgreja).update({
      'convite': convite,
    });
    return convite;
  }
}
