import 'package:flutter/material.dart';

import 'amizade.dart';
import 'comentario.dart';
import 'config.dart';
import 'postagem.dart';

// Mostra uma postagem: foto (se tiver), curtir, e a seção de comentários ou
// o botão de solicitar amizade, conforme a permissão que veio do servidor.
class CartaoPostagem extends StatefulWidget {
  final Postagem postagem;

  const CartaoPostagem({super.key, required this.postagem});

  @override
  State<CartaoPostagem> createState() => _CartaoPostagemState();
}

class _CartaoPostagemState extends State<CartaoPostagem> {
  late bool _curtida;
  late int _curtidas;
  bool _curtindo = false;
  bool _solicitandoAmizade = false;

  @override
  void initState() {
    super.initState();
    _curtida = widget.postagem.curtidaDoUsuario;
    _curtidas = widget.postagem.curtidas;
  }

  Future<void> _curtir() async {
    setState(() => _curtindo = true);
    try {
      final resultado = await curtirPostagem(widget.postagem.id);
      setState(() {
        _curtida = resultado.curtidaDoUsuario;
        _curtidas = resultado.curtidas;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _curtindo = false);
    }
  }

  Future<void> _solicitarAmizade() async {
    setState(() => _solicitandoAmizade = true);
    String mensagem;
    try {
      await solicitaAmizade(widget.postagem.usuarioId);
      mensagem = 'Solicitação de amizade enviada!';
    } catch (e) {
      mensagem = '$e';
    }
    if (!mounted) return;
    setState(() => _solicitandoAmizade = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    final postagem = widget.postagem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: postagem.caminho == null
              ? const Center(child: Text('Sem foto'))
              : Image.network(
                  'http://$servidor/${postagem.caminho}',
                  errorBuilder: (context, erro, stack) =>
                      const Center(child: Text('Sem foto')),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          'Por ${postagem.autor ?? 'desconhecido'}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(postagem.texto, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _curtindo ? null : _curtir,
              icon: Icon(
                _curtida ? Icons.favorite : Icons.favorite_border,
                color: _curtida ? Colors.red : null,
              ),
            ),
            Text('$_curtidas'),
          ],
        ),
        if (postagem.podeComentar)
          _Comentarios(postagemId: postagem.id)
        else
          ElevatedButton(
            onPressed: _solicitandoAmizade ? null : _solicitarAmizade,
            child: const Text('Solicitar amizade'),
          ),
      ],
    );
  }
}

class _Comentarios extends StatefulWidget {
  final int postagemId;

  const _Comentarios({required this.postagemId});

  @override
  State<_Comentarios> createState() => _ComentariosState();
}

class _ComentariosState extends State<_Comentarios> {
  final _controller = TextEditingController();
  late Future<List<Comentario>> _comentariosFuturo;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _comentariosFuturo = buscaComentarios(widget.postagemId);
  }

  Future<void> _comentar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() => _enviando = true);
    try {
      await salvaComentario(widget.postagemId, texto);
      _controller.clear();
      setState(() {
        _comentariosFuturo = buscaComentarios(widget.postagemId);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const Text('Comentários', style: TextStyle(fontWeight: FontWeight.bold)),
        FutureBuilder<List<Comentario>>(
          future: _comentariosFuturo,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Text('Carregando...');
            }
            final lista = snapshot.data!;
            if (lista.isEmpty) {
              return const Text('Nenhum comentário ainda');
            }
            return Column(
              children: [
                for (final comentario in lista)
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                        Text('${comentario.autor ?? 'Usuário'}: ${comentario.texto}'),
                  ),
              ],
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration:
                    const InputDecoration(hintText: 'Escreva um comentário'),
              ),
            ),
            IconButton(
              onPressed: _enviando ? null : _comentar,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }
}
