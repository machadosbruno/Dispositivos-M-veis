import 'package:flutter/material.dart';
import 'retorna.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Escolher(),
    );
  }
}

class Escolher extends StatefulWidget {
  const Escolher({super.key});

  @override
  State<Escolher> createState() => _EscolherState();
}

class _EscolherState extends State<Escolher> {
  final itens = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  String resposta = '';

  Future<void> esperaResposta(int x, BuildContext context) async {
    final resultado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => Teste(x)),
    );

    if (!context.mounted) return;

    final valorDigitado = int.tryParse(resultado ?? '');
    final respostaCorreta = x + 3;

    setState(() {
      if (valorDigitado == null) {
        resposta = 'Nenhuma resposta enviada.';
      } else if (valorDigitado == respostaCorreta) {
        resposta = 'Acertou! $x + 3 = $respostaCorreta';
      } else {
        resposta = 'Errou! Digitou $valorDigitado, mas o correto é $respostaCorreta';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...itens.map((e) {
              return ElevatedButton(
                child: Text(e.toString()),
                onPressed: () {
                  esperaResposta(e, context);
                },
              );
            }),
            const SizedBox(height: 20),
            Text(
              resposta,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}