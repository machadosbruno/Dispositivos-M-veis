import 'package:flutter/material.dart';
import 'package:flutter_application_2/pergunta.dart';
import 'package:flutter_application_2/questoes.dart';

class Janela2 extends StatefulWidget {
  const Janela2({
    super.key,
  });

  @override
  State<Janela2> createState() => _Janela2State();
}

class _Janela2State extends State<Janela2> {

  int qualPergunta = 0;
  
  @override
  Widget build(BuildContext context) {
    Pergunta teste1 = questoes[qualPergunta];
    List<String> perguntas = teste1.Embaralha();
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
                setState(() {
                  if(qualPergunta >= questoes.length-1){
                    qualPergunta = -1;
                  }
                  qualPergunta = qualPergunta + 1;
                  teste1 = questoes[qualPergunta];
                  perguntas = teste1.Embaralha();
                });
                
              },
              child: Text(resposta),
            );
          }),
        ],
      ),
    );
  }
}
