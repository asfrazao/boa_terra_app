import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boa_terra_app/models/evento_model.dart';

class EventoService {
  final CollectionReference _ref = FirebaseFirestore.instance.collection('eventos');

  /// Salvar novo evento
  Future<void> criarEvento(EventoModel evento) async {
    await _ref.add(evento.toMap());
  }

  /// Atualizar evento existente
  Future<void> atualizarEvento(String id, EventoModel eventoAtualizado) async {
    await _ref.doc(id).update(eventoAtualizado.toMap());
  }

  /// Excluir evento
  Future<void> excluirEvento(String id) async {
    await _ref.doc(id).delete();
  }

  /// Obter todos os eventos da igreja (com filtro por validade futura)
  Future<List<EventoModel>> listarEventos(String igrejaId) async {
    final snapshot = await _ref
        .where('igrejaId', isEqualTo: igrejaId)
        .where('dataExpiracao', isGreaterThan: Timestamp.now())
        .orderBy('dataEvento', descending: false)
        .get();

    return snapshot.docs.map((doc) => EventoModel.fromDoc(doc)).toList();
  }
}
