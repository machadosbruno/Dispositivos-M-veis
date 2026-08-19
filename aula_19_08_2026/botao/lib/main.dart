import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(NovaApp());
}

class NovaApp extends StatefulWidget {
  const NovaApp({super.key});

  @override
  State<NovaApp> createState() => _NovaAppState();
}

class _NovaAppState extends State<NovaApp> {
  int x = 0;
  int y = Random().nextInt(5) + 1;

  String acertou = '';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tente adivinhar o número sorteado selecionando um dos números abaixo,'),
              Text(' caso você acerte, o número será sorteado novamente:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        x = 1;
                        if (x == y) {
                          acertou = 'Sim';
                          y = Random().nextInt(5);
                          y++;
                        } else {
                          acertou = 'Não';
                        }
                      });
                    },
                    child: const Text('1'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        x = 2;
                        if (x == y) {
                          acertou = 'Sim';
                          y = Random().nextInt(5);
                          y++;
                        } else {
                          acertou = 'Não';
                        }
                      });
                    },
                    child: const Text('2'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        x = 3;
                        if (x == y) {
                          acertou = 'Sim';
                          y = Random().nextInt(5);
                          y++;
                        } else {
                          acertou = 'Não';
                        }
                      });
                    },
                    child: const Text('3'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        x = 4;
                        if (x == y) {
                          acertou = 'Sim';
                          y = Random().nextInt(5);
                          y++;
                        } else {
                          acertou = 'Não';
                        }
                      });
                    },
                    child: const Text('4'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        x = 5;
                        if (x == y) {
                          acertou = 'Sim';
                          y = Random().nextInt(5);
                          y++;
                        } else {
                          acertou = 'Não';
                        }
                      });
                    },
                    child: const Text('5'),
                  )
                ],
              ),
              Column(children: [
                Text('Número selecionado: $x'),
                Text('Acertou? ' + acertou),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
