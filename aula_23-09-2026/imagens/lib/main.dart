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
  final itens = [
    'assets/foca.jpg',
    'assets/koala.jpg',
    'assets/onca.jpg',
    'assets/capivara.webp'
  ];

  Future<void> esperaResposta(int x, BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute<bool>(builder: (context) => Teste(x)),
    );

    if (!context.mounted) return;

    print('Respondeu: $resultado');
    if (resultado == true) {
      setState(() {
        itens.remove(x);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ...itens.map((e) {
            return GestureDetector(
              child: Image.asset(
                e,
                width: 150.0,
                fit: BoxFit.cover,
              ),
              onTap: () {
                print('clicou');
                //esperaResposta(e, context);
              },
            );
          }),
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
  var operacao = '';
  int numeroAleatorio = 0;
  int esperado = 0;
  String resultado = '';
  TextEditingController controlaTexto = TextEditingController();

  @override
  void initState() {
    numeroAleatorio = Random().nextInt(9) + 1;
    operacao = '${widget.x} + $numeroAleatorio';
    esperado = widget.x + numeroAleatorio;
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
              controller: controlaTexto,
            ),
            ElevatedButton(
                onPressed: () {
                  resultado = controlaTexto.text;
                  if (esperado.toString() == resultado) {
                    print('Retornando: true');
                    Navigator.pop(context, true);
                  } else {
                    print('Retornando: false');
                    Navigator.pop(context, false);
                  }
                },
                child: Text('Verificar'))
          ],
        ),
      ),
    );
  }
}
