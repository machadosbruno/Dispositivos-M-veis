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
  final imagens = [
    'https://commons.wikimedia.org/wiki/Special:FilePath/Capybara_(Hydrochoerus_hydrochaeris).JPG?width=200',
    'https://commons.wikimedia.org/wiki/Special:FilePath/Koala_climbing_tree.jpg?width=200',
    'https://commons.wikimedia.org/wiki/Special:FilePath/Giraffe_Mikumi_National_Park.jpg?width=200',
    'https://commons.wikimedia.org/wiki/Special:FilePath/Lion_waiting_in_Namibia.jpg?width=200',
    'https://commons.wikimedia.org/wiki/Special:FilePath/Tiger_in_Ranthambhore.jpg?width=200',
  ];
  final gostou = [false, false, false, false, false];
  int atual = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(imagens[atual], width: 200),
              GestureDetector(
                child: Icon(
                  gostou[atual] ? Icons.favorite : Icons.favorite_border,
                ),
                onTap: () {
                  setState(() {
                    gostou[atual] = !gostou[atual];
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    atual = (atual + 1) % imagens.length;
                  });
                },
                child: const Text('Próxima'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
