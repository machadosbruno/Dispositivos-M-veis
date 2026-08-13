import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  print('Sim apertado');
                },
                child: const Text('Sim'),
              ),
              TextButton(
                onPressed: () {
                  print('Não apertado');
                },
                child: const Text('Não'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
