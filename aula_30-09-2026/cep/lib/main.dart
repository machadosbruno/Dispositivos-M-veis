import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Postagem> buscaPostagem(String id) async {
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
  final int id;
  final String title;
  final double rating;
  final double price;
  final String category;

  const Postagem(
      {required this.rating,
      required this.id,
      required this.title,
      required this.price,
      required this.category});

  factory Postagem.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'title': String title,
        'rating': num rating,
        'price': num price,
        'category': String category
      } =>
        Postagem(
            id: id,
            title: title,
            rating: rating.toDouble(),
            price: price.toDouble(),
            category: category),
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
              TextField(
                controller: _MenuController,
              ),
              ElevatedButton(
                child: Text('Próximo post'),
                onPressed: () {
                  setState(() {
                    id = (int.parse(id) + 1).toString();
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
                          Text('Título: ${snapshot.data!.title}'),
                          const SizedBox(height: 10),
                          Text('Categoria: ${snapshot.data!.category}'),
                          const SizedBox(height: 10),
                          Text('Avaliação: ${snapshot.data!.rating}'),
                          const SizedBox(height: 10),
                          Text('Preço: ${snapshot.data!.price}'),
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
