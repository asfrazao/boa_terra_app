import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/igreja_model.dart';

class IgrejaService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('igrejas');

  Future<List<IgrejaModel>> buscarPorChave(String chave) async {
    final snapshot = await _collection
        .where('chave', isEqualTo: chave.toUpperCase())
        .get();

    return snapshot.docs
        .map((doc) => IgrejaModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<String> salvarOuAtualizar(IgrejaModel igreja) async {
    final data = igreja.toMap();

    try {
      if (igreja.id != null && igreja.id!.isNotEmpty) {
        await _collection.doc(igreja.id).update(data);
        return igreja.id!;
      } else {
        final docRef = await _collection.add(data);
        return docRef.id;
      }
    } catch (e) {
      throw Exception('Erro ao salvar ou atualizar igreja: $e');
    }
  }


  Future<void> excluir(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> atualizarConvite(String id, String convite) async {
    await _collection.doc(id).update({
      'convite': convite,
    });
  }

  Future<IgrejaModel?> buscarPorId(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists) {
      return IgrejaModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<IgrejaModel>> listarTodas() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map(
            (doc) => IgrejaModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)
    ).toList();
  }


}
