import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// endereço do servidor (XAMPP)
const servidor = '10.106.76.14';

// buscaFoto.php devolve a imagem do registro com o id informado
String urlFoto(int id) => 'http://$servidor/buscaFoto.php?id=$id';

// listaFotos.php devolve todas as fotos em um array JSON
Future<List<String>> buscaCaminhos() async {
  final resposta = await http.get(
    Uri.http(servidor, '/listaFotos.php'),
    headers: {'Accept': 'application/json'},
  );

  if (resposta.statusCode != 200) {
    throw 'Falha ao carregar as fotos.';
  }
  final lista = jsonDecode(resposta.body) as List<dynamic>;
  return [for (final item in lista) 'http://$servidor/${item['caminho']}'];
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
        length: 3, // quantidade de abas
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Três abas'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.add_a_photo)),
                Tab(icon: Icon(Icons.photo_library)),
                Tab(icon: Icon(Icons.grid_view)),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              TelaInserir(),
              TelaListar(),
              TelaTodas(),
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
    if (foto == null) return;

    String mensagem;
    try {
      final requisicao = http.MultipartRequest(
        'POST',
        Uri.http(servidor, '/salvaFoto.php'),
      );
      requisicao.files.add(await http.MultipartFile.fromPath('foto', foto.path));

      final resposta = await http.Response.fromStream(await requisicao.send());
      final salvou = resposta.statusCode == 200 &&
          resposta.body.trim().startsWith('Foto salva!');
      mensagem = salvou ? resposta.body.trim() : 'Erro ao salvar!';
      if (salvou) {
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
            onPressed: foto == null ? null : _enviar,
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
  int _id = 1; // id da foto mostrada

  void _proximo() {
    setState(() {
      _id++;
    });
  }

  void _anterior() {
    setState(() {
      _id--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Foto $_id', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Expanded(
            child: Image.network(
              urlFoto(_id),
              key: ValueKey(_id), // força recarregar ao trocar de id
              loadingBuilder: (context, child, progresso) {
                if (progresso == null) return child;
                return const Center(child: Text('Carregando...'));
              },
              // buscaFoto.php responde texto quando o id não existe
              errorBuilder: (context, erro, stack) =>
                  const Center(child: Text('Sem foto com esse id')),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _proximo,
            child: const Text('Próximo'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _id > 1 ? _anterior : null,
            child: const Text('Anterior'),
          ),
        ],
      ),
    );
  }
}

class TelaTodas extends StatefulWidget {
  const TelaTodas({super.key});

  @override
  State<TelaTodas> createState() => _TelaTodasState();
}

class _TelaTodasState extends State<TelaTodas> {
  late Future<List<String>> _fotosFuturo;

  void _recarregar() {
    setState(() {
      _fotosFuturo = buscaCaminhos();
    });
  }

  @override
  void initState() {
    super.initState();
    _fotosFuturo = buscaCaminhos();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _fotosFuturo,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('Carregando...'));
                }
                final fotos = snapshot.data!;
                if (fotos.isEmpty) {
                  return const Center(child: Text('Nenhuma foto salva'));
                }
                return ListView.separated(
                  itemCount: fotos.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => Image.network(fotos[i]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _recarregar,
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }
}
