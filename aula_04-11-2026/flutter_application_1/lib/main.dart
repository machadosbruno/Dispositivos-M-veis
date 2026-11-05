import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// resposta do busca.php quando não há registro com id maior
const semMaisIds = 'Erro -> sem mais ids';

// busca.php devolve o primeiro registro com id maior que o informado
Future<Registro> buscaRegistro(int id) async {
  final resposta = await http.get(
    Uri.parse('http://10.106.76.14/busca.php?id=$id'),
    headers: {'Accept': 'application/json'},
  );

  if (resposta.statusCode != 200) {
    throw 'Falha ao carregar o texto.';
  }
  if (resposta.body.trim() == semMaisIds) {
    return const Registro(id: 0, texto: semMaisIds); // id 0 = fim da lista
  }
  return Registro.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
}

class Registro {
  final int id;
  final String texto;

  const Registro({required this.id, required this.texto});

  factory Registro.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'id': int id, 'texto': String texto} => Registro(id: id, texto: texto),
      _ => throw const FormatException('Falha no carregamento...'),
    };
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2, // quantidade de abas
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Duas abas'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.edit_note)),
                Tab(icon: Icon(Icons.list_alt)),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              TelaInserir(),
              TelaListar(),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaInserir extends StatefulWidget {
  const TelaInserir({super.key});

  @override
  State<TelaInserir> createState() => _TelaInserirState();
}

class _TelaInserirState extends State<TelaInserir> {
  final _controller = TextEditingController();

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    String mensagem;
    try {
      final resposta = await http.get(
        Uri.http('10.106.76.14', '/salva.php', {'txt': texto}),
      );
      final salvou =
          resposta.statusCode == 200 && resposta.body.trim() == 'Texto salvo!';
      mensagem = salvou ? 'Texto salvo!' : 'Erro ao salvar!';
      if (salvou) _controller.clear();
    } catch (e) {
      mensagem = 'Falha na conexão: $e';
    }

    if (!mounted) return; // a tela pode ter sido fechada durante a espera
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            maxLength: 200,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Digite o texto',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _enviar,
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

class TelaListar extends StatefulWidget {
  const TelaListar({super.key});

  @override
  State<TelaListar> createState() => _TelaListarState();
}

class _TelaListarState extends State<TelaListar> {
  final List<Registro> _vistos = []; // textos já mostrados, em ordem
  late Future<Registro> _registroFuturo;

  Future<Registro> _carregar(int id) async {
    final registro = await buscaRegistro(id);
    if (registro.id != 0) _vistos.add(registro);
    return registro;
  }

  void _proximo() {
    setState(() {
      _registroFuturo = _carregar(_vistos.isEmpty ? 0 : _vistos.last.id);
    });
  }

  void _voltarAoPrimeiro() {
    setState(() {
      _vistos.clear();
      _registroFuturo = _carregar(0);
    });
  }

  void _anterior(bool foraDaLista) {
    setState(() {
      // no fim ou com erro, o último da lista já é o texto anterior
      if (!foraDaLista) _vistos.removeLast();
      _registroFuturo = Future.value(_vistos.last);
    });
  }

  @override
  void initState() {
    super.initState();
    _registroFuturo = _carregar(0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<Registro>(
        future: _registroFuturo,
        builder: (context, snapshot) {
          final carregando =
              snapshot.connectionState == ConnectionState.waiting;
          final semMais = snapshot.data?.id == 0;
          final foraDaLista = semMais || snapshot.hasError;
          final temAnterior =
              foraDaLista ? _vistos.isNotEmpty : _vistos.length > 1;

          String mensagem = 'Carregando...';
          if (snapshot.hasData) {
            mensagem = snapshot.data!.texto;
          } else if (snapshot.hasError) {
            mensagem = '${snapshot.error}';
          }

          return Column(
            children: [
              Text(mensagem),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: carregando
                    ? null
                    : (semMais ? _voltarAoPrimeiro : _proximo),
                child: Text(semMais ? 'Voltar ao primeiro' : 'Próximo'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: carregando || !temAnterior
                    ? null
                    : () => _anterior(foraDaLista),
                child: const Text('Anterior'),
              ),
            ],
          );
        },
      ),
    );
  }
}
