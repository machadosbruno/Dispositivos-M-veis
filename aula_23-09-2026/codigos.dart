// gesture

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: GestureDetector(
            // child: Text('Aperte!'),
            child: Image.network(
                'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/63/Neptune_-_Voyager_2_%2829347980845%29_flatten_crop.jpg/960px-Neptune_-_Voyager_2_%2829347980845%29_flatten_crop.jpg'),
            onTap: () {
              print('Apertado!');
            },
          ),
        ),
      ),
    );
  }
}

// nova janela

import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Navigation Basics',
      home: PrimeiraJanela(),
    ),
  );
}

class PrimeiraJanela extends StatelessWidget {
  const PrimeiraJanela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Janela 1')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Acessar'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => SegundaJanela(53),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SegundaJanela extends StatelessWidget {
  SegundaJanela(this.x, {super.key});

  int x;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Segunda Janela')),
      body: Center(
        child: Column(
          children: [
            Text('Recebido: $x'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Voltar!'),
            ),
          ],
        ),
      ),
    );
  }
}

// enviar dados

import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ...itens.map((e) {
            return ElevatedButton(
              child: Text(e.toString()),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => Teste(e)),
                );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ida')),
      body: Center(child: Text('Recebido: ${widget.x}')),
    );
  }
}

// retornar dados

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

  Future<void> esperaResposta(int x, BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute<String>(builder: (context) => Teste(x)),
    );

    if (!context.mounted) return;

    print('Respondeu: $resultado');
    setState(() {
      resposta = 'Retorno: ' + (resultado ?? 'nada');
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
  TextEditingController controlaTexto = TextEditingController();

  @override
  void initState() {
    operacao = '${widget.x} + 3';
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
                  print('Retornando: $resultado');
                  Navigator.pop(context, resultado);
                },
                child: Text('Verificar'))
          ],
        ),
      ),
    );
  }
}

// aula8_codigo6.dart

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

  Future<void> esperaResposta(int x, BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute<bool>(builder: (context) => Teste(x)),
    );

    if (!context.mounted) return;

    print('Respondeu: $resultado');
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

// aula8_codigo7.dart

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
            return ElevatedButton(
              child: Text(e.toString()),
              onPressed: () {
                esperaResposta(e, context);
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
