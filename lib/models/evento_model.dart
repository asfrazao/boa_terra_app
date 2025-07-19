import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums/validade_mensagem.dart';

class EventoModel {
  final String id;
  final String titulo;
  final String mensagem;
  final String igrejaId;
  final String remetenteId;
  final List<String> visivelPara;
  final DateTime dataEvento;
  final DateTime dataEnvio;
  final DateTime dataExpiracao;

  EventoModel({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.igrejaId,
    required this.remetenteId,
    required this.visivelPara,
    required this.dataEvento,
    required this.dataEnvio,
    required this.dataExpiracao,
  });

  factory EventoModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventoModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      mensagem: data['mensagem'] ?? '',
      igrejaId: data['igrejaId'] ?? '',
      remetenteId: data['remetenteId'] ?? '',
      visivelPara: List<String>.from(data['visivelPara'] ?? []),
      dataEvento: (data['dataEvento'] as Timestamp).toDate(),
      dataEnvio: (data['dataEnvio'] as Timestamp).toDate(),
      dataExpiracao: (data['dataExpiracao'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'mensagem': mensagem,
      'igrejaId': igrejaId,
      'remetenteId': remetenteId,
      'visivelPara': visivelPara,
      'dataEvento': Timestamp.fromDate(dataEvento),
      'dataEnvio': Timestamp.fromDate(dataEnvio),
      'dataExpiracao': Timestamp.fromDate(dataExpiracao),
    };
  }

  static DateTime calcularExpiracao() {
    final agora = DateTime.now();
    return agora.add(ValidadeMensagem.evento.duracao);
  }
}
