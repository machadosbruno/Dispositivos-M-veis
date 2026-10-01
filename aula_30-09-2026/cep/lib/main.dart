import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Postagem> buscaPostagem(String id) async {
  print('Buscando postagem $id...');
  final resposta = await http.get(
    Uri.parse('https://viacep.com.br/ws/$id/json/'),
    headers: {'Accept': 'application/json'},
  );

  if (resposta.statusCode == 200) {
    // status 200 resposta OK
    return Postagem.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  } else {
    // status != 200 é erro!
    throw Exception('Falha ao carregar post.');
  }
}

class Postagem {
  final String logradouro;
  final String bairro;
  final String cidade;
  final String estado;

  const Postagem(
      {required this.logradouro,
      required this.bairro,
      required this.cidade,
      required this.estado});

  factory Postagem.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'logradouro': String logradouro,
        'bairro': String bairro,
        'localidade': String cidade,
        'estado': String estado
      } =>
        Postagem(
            logradouro: logradouro,
            bairro: bairro,
            cidade: cidade,
            estado: estado),
      _ => throw const FormatException('Falha no carregamento...'),
    };
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Postagem> postFuturo;
  final TextEditingController _MenuController = TextEditingController();
  var id;
  @override
  void initState() {
    super.initState();
    id = '01001000';
    postFuturo = Future<Postagem>.value( const Postagem(
      logradouro: '',
      bairro: '',
      cidade: '',
      estado: ''));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscando dados',
      home: Scaffold(
        appBar: AppBar(title: const Text('Buscando dados')),
        body: Center(
          child: Column(
            children: [
              TextField(
                controller: _MenuController,
              ),
              ElevatedButton(
                child: Text('Verificar endereço do CEP'),
                onPressed: () {
                  setState(() {
                    id = _MenuController.text;
                    postFuturo = buscaPostagem(id);
                  });
                },
              ),
              FutureBuilder<Postagem>(
                  future: postFuturo,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Text('Logradouro: ${snapshot.data!.logradouro}'),
                          const SizedBox(height: 10),
                          Text('Bairro: ${snapshot.data!.bairro}'),
                          const SizedBox(height: 10),
                          Text('Cidade: ${snapshot.data!.cidade}'),
                          const SizedBox(height: 10),
                          Text('Estado: ${snapshot.data!.estado}'),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return Text('Carregando...');
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
