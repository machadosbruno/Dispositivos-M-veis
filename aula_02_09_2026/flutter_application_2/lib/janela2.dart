import 'package:flutter/material.dart';
import 'package:flutter_application_2/pergunta.dart';
import 'package:flutter_application_2/questoes.dart';

class Janela2 extends StatelessWidget {
  const Janela2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Pergunta teste1 = questoes[0];
    List<String> perguntas = teste1.embaralha();
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/imagens/palhaco_ouve.png',
                //color: const Color.fromARGB(40, 244, 67, 54),
              ),
            ),
          ),
          Text(teste1.textoPergunta),
          ...perguntas.map((resposta) {
            return ElevatedButton(
              onPressed: () {
                if (resposta == teste1.respostas.first) {
                  print("Acertou!");
                } else {
                  print("Errou!");
                }
              },
              child: Text(resposta),
            );
          }),
        ],
      ),
    );
  }
}
