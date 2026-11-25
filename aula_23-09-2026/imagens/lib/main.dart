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
  final itens = [
    'https://commons.wikimedia.org/wiki/Special:FilePath/Capybara_(Hydrochoerus_hydrochaeris).JPG?width=100',
    'https://commons.wikimedia.org/wiki/Special:FilePath/Koala_climbing_tree.jpg?width=100',
    'https://commons.wikimedia.org/wiki/Special:FilePath/Giraffe_Mikumi_National_Park.jpg?width=100',
    'https://commons.wikimedia.org/wiki/Special:FilePath/Lion_waiting_in_Namibia.jpg?width=100',
    'https://commons.wikimedia.org/wiki/Special:FilePath/Tiger_in_Ranthambhore.jpg?width=100',
  ];
  final aprovadas = <String>[];

  Future<void> esperaResposta(String x, BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute<bool>(builder: (context) => Avaliar(x)),
    );

    if (!context.mounted) return;

    print('Respondeu: $resultado');
    if (resultado == true && !aprovadas.contains(x)) {
      setState(() {
        aprovadas.add(x);
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
              child: Image.network(
                e,
                width: 100.0,
                fit: BoxFit.cover,
              ),
              onTap: () {
                esperaResposta(e, context);
              },
            );
          }),
          ElevatedButton(
            child: Text('Ver aprovadas'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Resultado(aprovadas)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Avaliar extends StatelessWidget {
  const Avaliar(this.imagem, {super.key});

  final String imagem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar')),
      body: Center(
        child: Column(
          children: [
            Image.network(imagem, width: 200.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Aprovar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Reprovar'),
            ),
          ],
        ),
      ),
    );
  }
}

class Resultado extends StatelessWidget {
  const Resultado(this.aprovadas, {super.key});

  final List<String> aprovadas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aprovadas')),
      body: Column(
        children: [
          ...aprovadas.map((e) {
            return Image.network(e, width: 100.0);
          }),
        ],
      ),
    );
  }
}
