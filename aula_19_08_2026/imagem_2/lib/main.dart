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
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bart',
                    style: TextStyle(
                      fontSize: 50.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    'O seu bagunceiro preferido! :) :) :)',
                    style: TextStyle(fontSize: 30.0),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                      'Ligue para encomendar sua travessura: +55 (17) 30130-7070.',
                      style: TextStyle(fontSize: 25.0)),
                  Text('Obs.: Se não der certo 70 de novo ;)'),
                ],
              ),
              Column(
                children: [
                  Image.asset(
                    'imagens/bart.jpg',
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
