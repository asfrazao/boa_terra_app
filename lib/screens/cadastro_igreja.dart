import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class CadastroIgrejaScreen extends StatefulWidget {
  const CadastroIgrejaScreen({super.key});

  @override
  State<CadastroIgrejaScreen> createState() => _CadastroIgrejaScreenState();
}

class _CadastroIgrejaScreenState extends State<CadastroIgrejaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController chaveController = TextEditingController();
  final TextEditingController denominacaoController = TextEditingController();
  final TextEditingController adminController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController pastorNomeController = TextEditingController();
  final TextEditingController pastorSobrenomeController = TextEditingController();
  final TextEditingController coPastorController = TextEditingController();
  final TextEditingController coPastorSobrenomeController = TextEditingController();

  bool acessoValidado = false;

  final List<String> chavesValidas = ['SEARA25XZ7K8D', 'SEARA2025A'];

  final List<String> diasDaSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
  final Map<String, TimeOfDay> horariosCulto = {};
  final Map<String, bool> diasSelecionados = {};

  String? estadoSelecionado;

  final List<String> estadosBrasil = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];

  @override
  void initState() {
    super.initState();
    for (var dia in diasDaSemana) {
      diasSelecionados[dia] = false;
      horariosCulto[dia] = const TimeOfDay(hour: 19, minute: 30);
    }
  }

  void validarChave() {
    if (chavesValidas.contains(chaveController.text.trim())) {
      setState(() {
        acessoValidado = true;
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Chave inválida'),
          content: Text('A chave de acesso fornecida é inválida.'),
        ),
      );
    }
  }

  DateTime _timeOfDayToDateTime(TimeOfDay tod) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro Igreja/Setor")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: chaveController,
              decoration: const InputDecoration(
                labelText: 'Chave de Acesso',
                border: OutlineInputBorder(),
              ),
              enabled: !acessoValidado,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: acessoValidado ? null : validarChave,
              child: const Text('Validar Chave'),
            ),
            const SizedBox(height: 20),
            if (acessoValidado) Expanded(child: buildFormulario()),
          ],
        ),
      ),
    );
  }

  Widget buildFormulario() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            buildInput(denominacaoController, 'Denominação'),
            buildInput(adminController, 'Admin/Setor (opcional)', obrigatorio: false),
            DropdownButtonFormField<String>(
              value: estadoSelecionado,
              items: estadosBrasil.map((estado) {
                return DropdownMenuItem(value: estado, child: Text(estado));
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  estadoSelecionado = valor;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            buildInput(cidadeController, 'Cidade'),
            buildInput(bairroController, 'Bairro'),
            buildInput(enderecoController, 'Endereço'),
            buildInput(numeroController, 'Número'),
            buildInput(pastorNomeController, 'Nome do Pastor'),
            buildInput(pastorSobrenomeController, 'Sobrenome do Pastor'),
            buildInput(coPastorController, 'Co-Pastor (opcional)', obrigatorio: false),
            buildInput(coPastorSobrenomeController, 'Sobrenome Co-Pastor (opcional)', obrigatorio: false),
            const SizedBox(height: 20),
            const Text(
              'Dias e Horários dos Cultos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...diasDaSemana.map((dia) {
              return CheckboxListTile(
                title: Text(dia),
                value: diasSelecionados[dia],
                onChanged: (valor) {
                  setState(() {
                    diasSelecionados[dia] = valor!;
                  });
                },
                subtitle: diasSelecionados[dia]!
                    ? TimePickerSpinner(
                  time: _timeOfDayToDateTime(horariosCulto[dia]!),
                  is24HourMode: true,
                  normalTextStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  highlightedTextStyle: const TextStyle(fontSize: 20, color: Colors.black),
                  spacing: 30,
                  itemHeight: 30,
                  isForce2Digits: true,
                  onTimeChange: (time) {
                    setState(() {
                      horariosCulto[dia] = TimeOfDay.fromDateTime(time);
                    });
                  },
                )
                    : null,
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  for (var dia in diasDaSemana) {
                    if (diasSelecionados[dia]!) {
                      final hora = horariosCulto[dia]!;
                      print('$dia: ${hora.hour}:${hora.minute}');
                    }
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cadastro concluído com sucesso!')),
                  );
                }
              },
              child: const Text('Salvar Cadastro'),
            )
          ],
        ),
      ),
    );
  }

  Widget buildInput(TextEditingController controller, String label, {bool obrigatorio = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: obrigatorio
            ? (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null
            : null,
      ),
    );
  }
}
