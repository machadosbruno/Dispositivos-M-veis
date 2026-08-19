import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset('assets/imagens/palhaco.jpg'),
          ),
          const Text('Aperte o botão para começar:'),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: null,
            child: Text('Iniciar'),
          ),
        ],
      ),
    ),
  ));
}
