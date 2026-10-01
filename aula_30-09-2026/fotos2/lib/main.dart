import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Postagem> buscaPostagem(String id) async {
  final resposta = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
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
  final int userId;
  final int id;
  final String title;
  final String body;

  const Postagem(
      {required this.userId,
      required this.id,
      required this.title,
      required this.body});

  factory Postagem.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'userId': int userId,
        'id': int id,
        'title': String title,
        'body': String body
      } =>
        Postagem(
          userId: userId,
          id: id,
          title: title,
          body: body,
        ),
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
  var id;
  @override
  void initState() {
    super.initState();
    id = '1';
    postFuturo = buscaPostagem(id);
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
              FutureBuilder<Postagem>(
                  future: postFuturo,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Text(snapshot.data!.title),
                          const SizedBox(height: 10),
                          Text(snapshot.data!.body)
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return Text('Carregando...');
                  }),
              ElevatedButton(
                child: Text('Próximo post'),
                onPressed: () {
                  setState(() {
                    id = (int.parse(id) + 1).toString();
                    postFuturo = buscaPostagem(id);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
