import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Postagem> buscaPostagem() async {
  final resposta = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
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

  @override
  void initState() {
    super.initState();
    postFuturo = buscaPostagem();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscando dados',
      home: Scaffold(
        appBar: AppBar(title: const Text('Buscando dados')),
        body: Center(
            child: FutureBuilder<Postagem>(
          future: postFuturo,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.title);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            return Text('Carregando...');
          },
        )),
      ),
    );
  }
}
