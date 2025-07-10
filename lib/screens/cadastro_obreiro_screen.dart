import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/igreja_cadastro_controller.dart';

class CadastroIgrejaScreen extends StatelessWidget {
  const CadastroIgrejaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IgrejaCadastroController(),
      child: Consumer<IgrejaCadastroController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Cadastro de Igreja'),
              backgroundColor: Colors.deepPurple.shade100,
              foregroundColor: Colors.black,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: controller.chaveController,
                      decoration: const InputDecoration(
                        labelText: 'Chave de Acesso',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: controller.acessoValidado ? null : controller.validarChave,
                      child: const Text('Validar Chave'),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: controller.pastorSobrenomeController,
                      decoration: const InputDecoration(
                        labelText: 'Sobrenome do Pastor',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.coPastorController,
                      decoration: const InputDecoration(
                        labelText: 'Co-Pastor (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.coPastorSobrenomeController,
                      decoration: const InputDecoration(
                        labelText: 'Sobrenome Co-Pastor (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ✅ Campo de convite (somente leitura)
                    TextFormField(
                      readOnly: true,
                      enabled: false,
                      initialValue: controller.conviteGerado,
                      decoration: const InputDecoration(
                        labelText: 'Convite Gerado',
                        labelStyle: TextStyle(color: Colors.deepPurple),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Dias e Horários dos Cultos:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    // (Você pode adicionar aqui os checkboxes e time spinners para os cultos)

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.salvarCadastro,
                        child: const Text('Salvar Cadastro'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
