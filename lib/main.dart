import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // Caminho ajustado

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BOA TERRA APP',
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(), // Tela inicial definida corretamente
    );
  }
}