import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'welcome_screen.dart';

import '../controllers/igreja_cadastro_controller.dart';
import '../widgets/igreja_dropdown_list.dart';
import '../widgets/dias_horario_selector.dart';

class CadastroIgrejaScreen extends StatelessWidget {
  const CadastroIgrejaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IgrejaCadastroController(),
      child: const _CadastroIgrejaView(),
    );
  }
}

class _CadastroIgrejaView extends StatelessWidget {
  const _CadastroIgrejaView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<IgrejaCadastroController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro Igreja/Setor")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: controller.chaveController,
              decoration: const InputDecoration(
                labelText: 'Chave de Acesso',
                border: OutlineInputBorder(),
              ),
              enabled: !controller.acessoValidado,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.acessoValidado
                  ? null
                  : () async {
                final ok = await controller.validarChave();
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Chave inválida')),
                  );
                }
              },
              child: const Text('Validar Chave'),
            ),
            const SizedBox(height: 20),

            if (controller.acessoValidado)
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        IgrejaDropdownList(
                          igrejas: controller.igrejasEncontradas,
                          onEditar: controller.preencherCampos,
                          onExcluir: controller.excluirIgreja,
                        ),
                        _buildInput(controller.denominacaoController, 'Denominação'),
                        _buildInput(controller.adminController, 'Admin/Setor (opcional)', obrigatorio: false),

                        DropdownButtonFormField<String>(
                          value: controller.estadoSelecionado,
                          items: const [
                            'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS',
                            'MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO',
                          ].map((estado) {
                            return DropdownMenuItem(value: estado, child: Text(estado));
                          }).toList(),
                          onChanged: (valor) => controller.estadoSelecionado = valor,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInput(controller.cidadeController, 'Cidade'),
                        _buildInput(controller.bairroController, 'Bairro'),
                        _buildInput(controller.enderecoController, 'Endereço'),
                        _buildInput(controller.numeroController, 'Número'),
                        _buildInput(controller.pastorNomeController, 'Nome do Pastor'),
                        _buildInput(controller.pastorSobrenomeController, 'Sobrenome do Pastor'),
                        _buildInput(controller.coPastorController, 'Co-Pastor (opcional)', obrigatorio: false),
                        _buildInput(controller.coPastorSobrenomeController, 'Sobrenome Co-Pastor (opcional)', obrigatorio: false),

                        const SizedBox(height: 16),
                        // CAMPO DE CONVITE GERADO
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(text: controller.conviteGerado),
                          decoration: const InputDecoration(
                            labelText: 'Convite Gerado',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Text('Dias e Horários dos Cultos:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),

                        DiasHorarioSelector(
                          diasSelecionados: controller.diasSelecionados,
                          horariosCulto: controller.horariosCulto,
                          onSelecionarDia: (dia, ativo) {
                            controller.diasSelecionados[dia] = ativo;
                            if (ativo && controller.horariosCulto[dia]!.isEmpty) {
                              controller.horariosCulto[dia]!.add(const TimeOfDay(hour: 19, minute: 30));
                            }
                            controller.notifyListeners();
                          },
                          onEditarHorario: (dia, novo, index) {
                            controller.horariosCulto[dia]![index] = novo;
                            controller.notifyListeners();
                          },
                          onRemoverHorario: (dia, index) {
                            controller.horariosCulto[dia]!.removeAt(index);
                            controller.notifyListeners();
                          },
                          onAdicionarHorario: (dia) {
                            controller.horariosCulto[dia]!.add(const TimeOfDay(hour: 19, minute: 30));
                            controller.notifyListeners();
                          },
                        ),

                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              final bytes = await picked.readAsBytes();
                              if (bytes.lengthInBytes > 200 * 1024) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('❌ Imagem muito grande (máx: 200KB)')),
                                );
                                return;
                              }
                              controller.logoBase64 = base64Encode(bytes);
                              controller.notifyListeners();
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('Selecionar Logo da Igreja'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (controller.formKey.currentState!.validate()) {
                              await controller.salvarCadastro();

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✅ Cadastro salvo com sucesso!')),
                                );

                                Future.delayed(const Duration(milliseconds: 500), () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                                        (route) => false,
                                  );
                                });
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('⚠️ Preencha os campos obrigatórios.')),
                              );
                            }
                          },
                          child: const Text('Salvar Cadastro'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, {bool obrigatorio = true}) {
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
