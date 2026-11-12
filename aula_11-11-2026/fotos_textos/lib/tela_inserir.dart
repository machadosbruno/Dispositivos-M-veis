import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'config.dart';

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
    if (texto.isEmpty) return;

    String mensagem;
    try {
      final usuarioId = await usuarioLogado();

      // foto (quando houver) e texto vão juntos na mesma requisição
      final requisicao = http.MultipartRequest(
        'POST',
        Uri.http(servidor, '/salvaPostagem.php'),
      );
      requisicao.fields['usuario_id'] = '$usuarioId';
      requisicao.fields['txt'] = texto;
      if (foto != null) {
        requisicao.files
            .add(await http.MultipartFile.fromPath('foto', foto.path));
      }

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
