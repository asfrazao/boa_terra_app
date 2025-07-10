import 'package:flutter/material.dart';

class CampoSenha extends StatefulWidget {
  final TextEditingController senhaController;
  final TextEditingController repetirSenhaController;

  const CampoSenha({
    super.key,
    required this.senhaController,
    required this.repetirSenhaController,
  });

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _senhaVisivel = false;
  bool _repetirSenhaVisivel = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.senhaController,
          obscureText: !_senhaVisivel,
          decoration: InputDecoration(
            labelText: 'Senha (mín. 6 dígitos)',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _senhaVisivel ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _senhaVisivel = !_senhaVisivel;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campo obrigatório';
            }
            if (value.length < 6) {
              return 'Senha deve ter ao menos 6 dígitos';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: widget.repetirSenhaController,
          obscureText: !_repetirSenhaVisivel,
          decoration: InputDecoration(
            labelText: 'Repetir Senha',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _repetirSenhaVisivel ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _repetirSenhaVisivel = !_repetirSenhaVisivel;
                });
              },
            ),
          ),
          validator: (value) {
            if (value != widget.senhaController.text) {
              return 'As senhas não coincidem';
            }
            return null;
          },
        ),
      ],
    );
  }
}
