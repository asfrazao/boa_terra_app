import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boa_terra_app/models/evento_model.dart';
import 'package:boa_terra_app/services/evento_service.dart';
import 'package:boa_terra_app/models/enums/validade_mensagem.dart';

class GerenciarEventosScreen extends StatefulWidget {
  final String igrejaId;
  final String userId;

  const GerenciarEventosScreen({
    super.key,
    required this.igrejaId,
    required this.userId,
  });

  @override
  State<GerenciarEventosScreen> createState() => _GerenciarEventosScreenState();
}

class _GerenciarEventosScreenState extends State<GerenciarEventosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _mensagemController = TextEditingController();
  final _eventoService = EventoService();

  String? _modoEdicaoId;
  DateTime? _dataEventoSelecionada;
  List<String> _visivelPara = ['todos'];
  List<EventoModel> _eventos = [];

  @override
  void initState() {
    super.initState();
    _carregarEventos();
  }

  Future<void> _carregarEventos() async {
    final eventos = await _eventoService.listarEventos(widget.igrejaId);
    setState(() {
      _eventos = eventos;
    });
  }

  Future<void> _selecionarDataHoraEvento() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (data == null) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora == null) return;

    setState(() {
      _dataEventoSelecionada = DateTime(
        data.year,
        data.month,
        data.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  void _toggleDestinatario(String tipo) {
    setState(() {
      if (_visivelPara.contains(tipo)) {
        _visivelPara.remove(tipo);
      } else {
        _visivelPara = ['todos'] == tipo ? ['todos'] : [..._visivelPara.where((e) => e != 'todos'), tipo];
        if (_visivelPara.contains('todos') && _visivelPara.length > 1) {
          _visivelPara.removeWhere((e) => e != 'todos');
        }
      }
    });
  }

  Future<void> _salvarEvento() async {
    if (!_formKey.currentState!.validate() || _dataEventoSelecionada == null) return;

    final evento = EventoModel(
      id: _modoEdicaoId ?? '',
      titulo: _tituloController.text.trim(),
      mensagem: _mensagemController.text.trim(),
      igrejaId: widget.igrejaId,
      remetenteId: widget.userId,
      visivelPara: _visivelPara,
      dataEvento: _dataEventoSelecionada!,
      dataEnvio: DateTime.now(),
      dataExpiracao: EventoModel.calcularExpiracao(),
    );

    if (_modoEdicaoId != null) {
      await _eventoService.atualizarEvento(_modoEdicaoId!, evento);
    } else {
      await _eventoService.criarEvento(evento);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_modoEdicaoId == null
          ? '✅ Evento enviado com sucesso!'
          : '✅ Evento atualizado com sucesso!')),
    );

    _limparCampos();
    _carregarEventos();
  }

  void _limparCampos() {
    _tituloController.clear();
    _mensagemController.clear();
    _dataEventoSelecionada = null;
    _modoEdicaoId = null;
    _visivelPara = ['todos'];
    setState(() {});
  }

  void _prepararEdicao(EventoModel evento) {
    setState(() {
      _modoEdicaoId = evento.id;
      _tituloController.text = evento.titulo;
      _mensagemController.text = evento.mensagem;
      _dataEventoSelecionada = evento.dataEvento;
      _visivelPara = [...evento.visivelPara];
    });
  }

  Future<void> _confirmarExclusao(EventoModel evento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Evento'),
        content: const Text('Deseja realmente excluir este evento?'),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(context, false)),
          ElevatedButton(child: const Text('Excluir'), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (confirmar == true) {
      await _eventoService.excluirEvento(evento.id);
      _carregarEventos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Eventos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Visível para:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 12,
              children: ['todos', 'pastor', 'obreiro', 'membro'].map((tipo) {
                final label = tipo[0].toUpperCase() + tipo.substring(1);
                final ativo = _visivelPara.contains(tipo);
                return FilterChip(
                  label: Text(label),
                  selected: ativo,
                  onSelected: (_) => _toggleDestinatario(tipo),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(labelText: 'Título do Evento'),
                    validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _mensagemController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Descritivo do Evento'),
                    validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dataEventoSelecionada == null
                              ? 'Data e Hora do Evento não selecionadas'
                              : 'Evento: ${_dataEventoSelecionada!.day}/${_dataEventoSelecionada!.month} às ${_dataEventoSelecionada!.hour}h${_dataEventoSelecionada!.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Selecionar'),
                        onPressed: _selecionarDataHoraEvento,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _salvarEvento,
                          child: Text(_modoEdicaoId == null ? 'Enviar Evento' : 'Salvar Alterações'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_modoEdicaoId != null)
                        ElevatedButton(
                          onPressed: _limparCampos,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          child: const Text('Cancelar'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Eventos Cadastrados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._eventos.map((evento) => Card(
              child: ListTile(
                title: Text(evento.titulo),
                subtitle: Text('${evento.dataEvento.day}/${evento.dataEvento.month} às ${evento.dataEvento.hour}h${evento.dataEvento.minute.toString().padLeft(2, '0')}'),
                onTap: () => _mostrarDetalhesEvento(evento),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalhesEvento(EventoModel evento) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(evento.titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descrição: ${evento.mensagem}'),
            const SizedBox(height: 8),
            Text('Data do Evento: ${evento.dataEvento.day}/${evento.dataEvento.month}/${evento.dataEvento.year} - ${evento.dataEvento.hour}h${evento.dataEvento.minute.toString().padLeft(2, '0')}'),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
            onPressed: () {
              Navigator.pop(context);
              _prepararEdicao(evento);
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Excluir'),
            onPressed: () {
              Navigator.pop(context);
              _confirmarExclusao(evento);
            },
          ),
        ],
      ),
    );
  }
}
