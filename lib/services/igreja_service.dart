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

    if (igreja.id != null && igreja.id!.isNotEmpty) {
      await _collection.doc(igreja.id).update(data);
      return igreja.id!;
    } else {
      final docRef = await _collection.add(data);
      return docRef.id;
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
}
