import 'dart:math';

class ValidadorConvite {
  static const String prefixo = 'BOATERRA';

  /// Gera um código de convite seguro com base no ID da igreja
  static String gerarConvite(String idIgreja) {
    final random = Random.secure();
    const caracteres = 'ABCDEFGHJKMNOPQRSTUVWXYZ0123456789';
    final sufixo = List.generate(6, (_) => caracteres[random.nextInt(caracteres.length)]).join();
    return '$prefixo-$idIgreja-$sufixo';
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
        sufixo.length == 6 &&
        RegExp(r'^[A-Z0-9]{6}$').hasMatch(sufixo);
  }

  /// Retorna o ID da igreja presente no convite
  static String? extrairIdIgreja(String convite) {
    if (!validar(convite)) return null;
    return convite.split('-')[1];
  }
}
