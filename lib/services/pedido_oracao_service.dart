// lib/services/pedido_oracao_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enums/validade_mensagem.dart';

class PedidoOracaoService {
  final CollectionReference _ref = FirebaseFirestore.instance.collection('pedidos_oracao');

  Future<void> enviarPedido({
    required String igrejaId,
    required String userId,
    required String titulo,
    required String mensagem,
  }) async {
    final agora = Timestamp.now();
    final expiracao = Timestamp.fromDate(
      agora.toDate().add(ValidadeMensagem.pedidoOracao.duracao),
    );

    await _ref.add({
      'igrejaId': igrejaId,
      'enviadoPor': userId,
      'titulo': titulo.trim(),
      'mensagem': mensagem.trim(),
      'visivelPara': ['pastor', 'obreiro'],
      'tipo': 'pedido_oracao',
      'dataEnvio': agora,
      'dataExpiracao': expiracao,
      'lidasPor': [],
    });
  }
}
