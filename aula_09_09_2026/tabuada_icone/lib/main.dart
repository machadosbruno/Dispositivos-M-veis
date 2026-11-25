import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int a = Random().nextInt(9) + 1;
  int b = Random().nextInt(9) + 1;
  String resposta = '';
  TextEditingController controlaTexto = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // mostra o ícone conforme o que o usuário digitou
    Widget icone = const Icon(Icons.help_outline);
    if (resposta != '') {
      if (resposta == (a * b).toString()) {
        icone = const Icon(Icons.check, color: Colors.green);
      } else {
        icone = const Icon(Icons.close, color: Colors.red);
      }
    }

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$a x $b = ?'),
              TextField(
                controller: controlaTexto,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    resposta = value;
                  });
                },
              ),
              icone,
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    a = Random().nextInt(9) + 1;
                    b = Random().nextInt(9) + 1;
                    resposta = '';
                    controlaTexto.clear();
                  });
                },
                child: const Text('Nova operação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
