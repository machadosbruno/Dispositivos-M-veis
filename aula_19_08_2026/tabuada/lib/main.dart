import 'package:flutter/material.dart';
import 'package:tabuada/janela1.dart';
import 'package:tabuada/janela2.dart';

void main() {
  runApp(Controle());
}

class Controle extends StatefulWidget {
  const Controle({super.key});

  @override
  State<Controle> createState() => _ControleState();
}

class _ControleState extends State<Controle> {
  //Widget? atual; // precisa esperar muda ser criada
  var janela = 'um';

  @override
  void initState() {
    //atual = Janela1(muda); // espera a inicialização
    super.initState();
  }

  //criação de muda
  void muda() {
    setState(() {
      //atual = Janela2();
      janela = 'dois';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: janela == 'um' ? Janela1(muda) : Janela2(),
    );
  }
}
