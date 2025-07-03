class ValidadorChaveLocal {
  /// Valida se a chave fornecida é considerada válida
  static bool validar(String chave) {
    if (chave.isEmpty) return false;

    final valor = chave.trim().toUpperCase();

    // Regra 1: deve começar com "BOATERRA"
    if (!valor.startsWith('BOATERRA')) return false;

    // Regra 2: o sufixo (após BOATERRA) deve ter entre 4 e 8 caracteres alfanuméricos
    final sufixo = valor.substring(8); // tudo depois de "BOATERRA"

    final sufixoValido = RegExp(r'^[A-Z0-9]{4,8}$');
    return sufixoValido.hasMatch(sufixo);
  }
}
