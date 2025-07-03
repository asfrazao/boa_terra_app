import 'package:cloud_firestore/cloud_firestore.dart';

class IgrejaModel {
  final String? id;
  final String chave;
  final String denominacao;
  final String estado;
  final String cidade;
  final String bairro;
  final String endereco;
  final String numero;
  final String pastorNome;
  final String pastorSobrenome;
  final String? adminSetor;
  final String? coPastor;
  final String? coPastorSobrenome;
  final String logoBase64;
  final List<Map<String, String>> diasCultos;
  final DateTime? dataCadastro;
  final String? convite; // ✅ NOVO

  IgrejaModel({
    this.id,
    required this.chave,
    required this.denominacao,
    required this.estado,
    required this.cidade,
    required this.bairro,
    required this.endereco,
    required this.numero,
    required this.pastorNome,
    required this.pastorSobrenome,
    this.adminSetor,
    this.coPastor,
    this.coPastorSobrenome,
    required this.logoBase64,
    required this.diasCultos,
    this.dataCadastro,
    this.convite, // ✅ NOVO
  });

  factory IgrejaModel.fromMap(String id, Map<String, dynamic> map) {
    return IgrejaModel(
      id: id,
      chave: map['chave'] ?? '',
      denominacao: map['denominacao'] ?? '',
      estado: map['estado'] ?? '',
      cidade: map['cidade'] ?? '',
      bairro: map['bairro'] ?? '',
      endereco: map['endereco'] ?? '',
      numero: map['numero'] ?? '',
      pastorNome: map['pastor_nome'] ?? '',
      pastorSobrenome: map['pastor_sobrenome'] ?? '',
      adminSetor: map['admin_setor'],
      coPastor: map['copastor'],
      coPastorSobrenome: map['copastor_sobrenome'],
      logoBase64: map['logo_base64'] ?? '',
      diasCultos: (map['dias_cultos'] as List<dynamic>? ?? [])
          .map<Map<String, String>>((e) => Map<String, String>.from(e as Map))
          .toList(),
      dataCadastro: (map['dataCadastro'] as Timestamp?)?.toDate(),
      convite: map['convite'], // ✅ NOVO
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chave': chave,
      'denominacao': denominacao,
      'estado': estado,
      'cidade': cidade,
      'bairro': bairro,
      'endereco': endereco,
      'numero': numero,
      'pastor_nome': pastorNome,
      'pastor_sobrenome': pastorSobrenome,
      'admin_setor': adminSetor,
      'copastor': coPastor,
      'copastor_sobrenome': coPastorSobrenome,
      'logo_base64': logoBase64,
      'dias_cultos': diasCultos,
      'dataCadastro': dataCadastro ?? DateTime.now(),
      'convite': convite, // ✅ NOVO
    };
  }
}
