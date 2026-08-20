import 'package:flutter/material.dart';

class Janela2 extends StatelessWidget {
  const Janela2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/imagens/palhaco2.jpg',
                //color: Color.fromARGB(6, 145, 144, 144),
              ),
            ),
          ),
          const Text('1 + 1 = ?'),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Verificar'),
          ),
          
        ],
      ),
    );
  }
}