import 'package:flutter/material.dart';
import 'package:flutter_application_3/frases.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const Janela());
}

class Janela extends StatefulWidget {
  const Janela({super.key});

  @override
  State<Janela> createState() => _JanelaState();
}

class _JanelaState extends State<Janela> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Principal()),
    );
  }
}

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  FraseControle controlador = FraseControle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          controlador.fraseAtual.texto,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.normal,
          ),
        ),
        // icon
        GestureDetector(
          child: Icon(controlador.fraseAtual.like
              ? Icons.favorite
              : Icons.favorite_border),
          onTap: () => {
            setState(() {
              controlador.fraseAtual.mudaLike();
            }),
          },
        ),

        Text(
          controlador.fraseAtual.autor,
          style: GoogleFonts.msMadi(
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        ElevatedButton(
            onPressed: () {
              setState(() {
                controlador.proximaFrase();
              });
            },
            child: const Text('Próxima'))
      ],
    );
  }
}
