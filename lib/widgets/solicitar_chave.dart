import 'package:flutter/material.dart';

class SolicitarChaveScreen extends StatelessWidget {
  const SolicitarChaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solicitar Chave"),
        backgroundColor: Colors.purple.shade100,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Ajude o projeto com uma doação única\ne envie seu comprovante para:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const SelectableText(
              'boaterra.app@gmail.com',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 30),
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
              ),
              child: Image.asset('assets/images/qrcode.png', fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            const Text(
              'Use o QR Code acima para doar\nPix via chave aleatória.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
