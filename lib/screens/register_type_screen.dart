import 'package:boa_terra_app/screens/cadastro_pastor_screen.dart';
import 'package:flutter/material.dart';
import 'cadastro_igreja_screen.dart';
import 'cadastro_membro_screen.dart';// agora apontando para a nova tela


class RegisterTypeScreen extends StatefulWidget {
  const RegisterTypeScreen({super.key});

  @override
  State<RegisterTypeScreen> createState() => _RegisterTypeScreenState();
}

class _RegisterTypeScreenState extends State<RegisterTypeScreen> {
  String? tipoSelecionado;

  final List<String> opcoes = [
    'Igreja/Setor',
    'Pastor',
    'Obreiro',
    'Membro',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: Colors.purple.shade100,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Seja Bem-vindo!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Escolha o tipo de cadastro:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              hint: const Text('Selecione uma opção'),
              value: tipoSelecionado,
              onChanged: (value) {
                setState(() {
                  tipoSelecionado = value;
                });
              },
              items: opcoes.map((tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: tipoSelecionado != null
                    ? () {
                  if (tipoSelecionado == 'Igreja/Setor') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CadastroIgrejaScreen(),
                      ),
                    );
                  }
                  else if (tipoSelecionado == 'Membro') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CadastroMembroScreen(),
                      ),
                    );
                  }
                  else if (tipoSelecionado == 'Pastor') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CadastroPastorScreen(),
                      ),
                    );
                  }
                  // Você pode adicionar as outras rotas aqui no futuro
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade50,
                  foregroundColor: Colors.purple,
                ),
                child: const Text('Avançar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
