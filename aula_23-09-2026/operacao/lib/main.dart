import 'package:flutter/material.dart';

import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Escolher());
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
  String acertou = '';

  Future<void> esperaResposta(int x, BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute<String>(builder: (context) => Teste(x)),
    );

    if (!context.mounted) return;

    print('Respondeu: $resultado');
    setState(() {
      //resposta = 'Retorno: ' + (resultado ?? 'nada');
      resposta = (resultado ?? 'Falha ao receber a resposta');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ...itens.map((e) {
            return ElevatedButton(
              child: Text(e.toString()),
              onPressed: () {
                esperaResposta(e, context);
              },
            );
          }),
          Text(resposta),
        ],
      ),
    );
  }
}

class Teste extends StatefulWidget {
  Teste(this.x, {super.key});

  final int x;

  @override
  State<Teste> createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  var operacao = '1 + 1';
  String resultado = '';
  String acertou = '';
  TextEditingController controlaTexto = TextEditingController();

  @override
  void initState() {
    operacao = '${widget.x} + 3';
    acertou = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ida')),
      body: Center(
        child: Column(
          children: [
            Text(operacao),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              controller: controlaTexto,
            ),
            ElevatedButton(
                onPressed: () {
                  resultado = controlaTexto.text;
                  if (widget.x + 3 == int.parse(resultado)) {
                    acertou = 'Acertou';
                  } else {
                    acertou = 'Errou';
                  }

                  print('Retornando: $resultado');
                  Navigator.pop(context, acertou);
                },
                child: Text('Verificar'))
          ],
        ),
      ),
    );
  }
}
