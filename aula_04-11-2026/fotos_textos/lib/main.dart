import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// endereço do servidor (XAMPP)
const servidor = '10.106.76.14';

class Postagem {
  final int id;
  final String texto;
  final String caminho;

  const Postagem(
      {required this.id, required this.texto, required this.caminho});

  factory Postagem.fromJson(Map<String, dynamic> json) {
    return Postagem(
      id: int.parse('${json['id']}'),
      texto: json['texto'] as String,
      caminho: json['caminho'] as String,
    );
  }
}

// listaPostagens.php devolve todas as postagens em um array JSON
Future<List<Postagem>> buscaPostagens() async {
  final resposta = await http.get(
    Uri.http(servidor, '/listaPostagens.php'),
    headers: {'Accept': 'application/json'},
  );

  if (resposta.statusCode != 200) {
    throw 'Falha ao carregar as postagens.';
  }
  final lista = jsonDecode(resposta.body) as List<dynamic>;
  return [
    for (final item in lista) Postagem.fromJson(item as Map<String, dynamic>)
  ];
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
            title: const Text('Fotos e textos'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.add_a_photo)),
                Tab(icon: Icon(Icons.photo_library)),
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
  final _picker = ImagePicker();
  final _controller = TextEditingController();
  XFile? _foto; // foto escolhida, ainda não enviada

  Future<void> _escolher(ImageSource origem) async {
    final foto = await _picker.pickImage(source: origem);
    if (foto == null) return; // usuário cancelou
    setState(() {
      _foto = foto;
    });
  }

  Future<void> _enviar() async {
    final foto = _foto;
    final texto = _controller.text.trim();
    if (foto == null || texto.isEmpty) return;

    String mensagem;
    try {
      // foto e texto vão juntos na mesma requisição
      final requisicao = http.MultipartRequest(
        'POST',
        Uri.http(servidor, '/salvaPostagem.php'),
      );
      requisicao.fields['txt'] = texto;
      requisicao.files.add(await http.MultipartFile.fromPath('foto', foto.path));

      final resposta = await http.Response.fromStream(await requisicao.send());
      final salvou = resposta.statusCode == 200 &&
          resposta.body.trim().startsWith('Postagem salva!');
      mensagem = salvou ? resposta.body.trim() : 'Erro ao salvar!';
      if (salvou) {
        _controller.clear();
        setState(() {
          _foto = null;
        });
      }
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
    final foto = _foto;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: foto == null
                ? const Center(child: Text('Nenhuma foto escolhida'))
                : Image.file(File(foto.path)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: () => _escolher(ImageSource.gallery),
            child: const Text('Galeria'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _escolher(ImageSource.camera),
            child: const Text('Câmera'),
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
  late Future<List<Postagem>> _postagensFuturo;
  int _posicao = 0; // posição da postagem mostrada na lista

  void _atualizar() {
    setState(() {
      _posicao = 0;
      _postagensFuturo = buscaPostagens();
    });
  }

  @override
  void initState() {
    super.initState();
    _postagensFuturo = buscaPostagens();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<Postagem>>(
        future: _postagensFuturo,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Carregando...'));
          }

          final lista = snapshot.data!;
          if (lista.isEmpty) {
            return const Center(child: Text('Nenhuma postagem'));
          }
          final postagem = lista[_posicao];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  'http://$servidor/${postagem.caminho}',
                  key: ValueKey(postagem.id), // força recarregar ao trocar
                  errorBuilder: (context, erro, stack) =>
                      const Center(child: Text('Sem foto')),
                ),
              ),
              const SizedBox(height: 8),
              Text(postagem.texto, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _posicao < lista.length - 1
                    ? () => setState(() => _posicao++)
                    : null,
                child: const Text('Próximo'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed:
                    _posicao > 0 ? () => setState(() => _posicao--) : null,
                child: const Text('Anterior'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _atualizar,
                child: const Text('Atualizar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
