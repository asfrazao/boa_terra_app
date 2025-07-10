import 'package:url_launcher/url_launcher.dart';

class CompartilhadorConvite {
  static const String _mensagemBase = '🎫 Seu convite é:';

  /// Gera o link do WhatsApp com o convite e link do app
  static Future<void> compartilharConvite({
    required String convite,
    String? nomeIgreja,
    String linkApp = 'https://seuapp.com/download',
  }) async {
    final String texto = '''
📲 Olá! Seja bem-vindo(a) ao *Boa Terra App*!${nomeIgreja != null ? '\n\n🕊️ *$nomeIgreja* convidou você para se cadastrar.' : ''}

$_mensagemBase *$convite*

📥 Baixe o app agora mesmo e complete seu cadastro:
$linkApp
''';

    final Uri url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(texto)}');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw '❌ Não foi possível abrir o WhatsApp.';
    }
  }
}
