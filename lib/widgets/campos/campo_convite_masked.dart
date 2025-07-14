import 'package:flutter/material.dart';

class CampoConviteMasked extends StatelessWidget {
  final TextEditingController controllerParte1;
  final TextEditingController controllerParte2;
  final VoidCallback onValidar;
  final VoidCallback onCancelar;

  const CampoConviteMasked({
    super.key,
    required this.controllerParte1,
    required this.controllerParte2,
    required this.onValidar,
    required this.onCancelar,
  });


  @override
  Widget build(BuildContext context) {
    final focoParte2 = FocusNode();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'BOATERRA-',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: controllerParte1,
                textCapitalization: TextCapitalization.characters,
                maxLength: 3,
                decoration: const InputDecoration(
                  counterText: '',
                  enabledBorder: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value.length == 3) {
                    focoParte2.requestFocus();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextField(
                focusNode: focoParte2,
                controller: controllerParte2,
                textCapitalization: TextCapitalization.characters,
                maxLength: 3,
                decoration: const InputDecoration(
                  counterText: '',
                  enabledBorder: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: onValidar,
            icon: const Icon(Icons.vpn_key, size: 18),
            label: const Text('Validar Convite'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
