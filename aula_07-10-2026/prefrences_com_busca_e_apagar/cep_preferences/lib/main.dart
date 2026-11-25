import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controlador = TextEditingController();
  TextEditingController controladorNumero = TextEditingController();
  String rua = '';
  String bairro = '';
  String cidade = '';
  String estado = '';
  String mensagem = '';

  @override
  void initState() {
    super.initState();
    carregar();
  }

  // carrega os dados salvos na inicialização
  void carregar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      controlador.text = prefs.getString('cep') ?? '';
      controladorNumero.text = prefs.getString('numero') ?? '';
      rua = prefs.getString('rua') ?? '';
      bairro = prefs.getString('bairro') ?? '';
      cidade = prefs.getString('cidade') ?? '';
      estado = prefs.getString('estado') ?? '';
    });
  }

  // busca o endereço na API viacep
  void buscar() async {
    final resposta = await http.get(
      Uri.parse('https://viacep.com.br/ws/${controlador.text}/json/'),
    );
    final dados = jsonDecode(resposta.body);
    setState(() {
      if (resposta.statusCode == 200 && dados['erro'] == null) {
        rua = dados['logradouro'];
        bairro = dados['bairro'];
        cidade = dados['localidade'];
        estado = dados['estado'];
        mensagem = '';
      } else {
        mensagem = 'CEP não encontrado';
      }
    });
  }

  void salvar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cep', controlador.text);
    await prefs.setString('numero', controladorNumero.text);
    await prefs.setString('rua', rua);
    await prefs.setString('bairro', bairro);
    await prefs.setString('cidade', cidade);
    await prefs.setString('estado', estado);
    print('Salvando CEP: ${controlador.text}');
  }

  void apagar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    controlador.clear();
    controladorNumero.clear();
    setState(() {
      rua = '';
      bairro = '';
      cidade = '';
      estado = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Digite seu cep (somente números)!',
                    border: OutlineInputBorder(),
                  ),
                  controller: controlador,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Número',
                    border: OutlineInputBorder(),
                  ),
                  controller: controladorNumero,
                ),
              ),
              Text(mensagem),
              Text('Rua: $rua, ${controladorNumero.text}'),
              Text('Bairro: $bairro'),
              Text('Cidade: $cidade'),
              Text('Estado: $estado'),
              Row(
                children: [
                  ElevatedButton(onPressed: buscar, child: Text('Buscar')),
                  ElevatedButton(onPressed: salvar, child: Text('Salvar')),
                  ElevatedButton(onPressed: apagar, child: Text('Apagar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
