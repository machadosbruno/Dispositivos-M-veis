import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

Future<String> get _pastaDocumentos async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _arquivo async {
  final caminho = await _pastaDocumentos;
  return File('$caminho/organiza.md');
}

Future<File> escreveX(String x) async {
  final arquivo = await _arquivo;
  return arquivo.writeAsString('$x');
}

Future<String> lerX() async {
  try {
    final arquivo = await _arquivo;
    final conteudo = await arquivo.readAsString();
    return conteudo;
  } catch (_) {
    // se acontecer um erro
    return '';
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controlador = TextEditingController();
  String x = '';

  @override
  void initState() {
    super.initState();
    buscaX();
  }

  void buscaX() async {
    if (_arquivo == null) {
      String valor = await lerX();
      setState(() {
        x = valor;
      });
    }
    print('Mostrando x: $x');
  }

  void salvar() async {
    escreveX(controlador.text);

    print('Salvando x:' + controlador.text);
    buscaX();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Text('Antes de salvar: $x'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Digite seu texto em Mark Down!',
                    border: OutlineInputBorder(),
                  ),
                  controller: controlador,
                ),
              ),
              Row(
                children: [
                  ElevatedButton(onPressed: salvar, child: Text('Salvar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
