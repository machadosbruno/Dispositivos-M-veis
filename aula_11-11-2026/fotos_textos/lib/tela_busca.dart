import 'package:flutter/material.dart';

import 'busca.dart';
import 'cartao_postagem.dart';
import 'cartao_usuario.dart';
import 'postagem.dart';
import 'tela_perfil_usuario.dart';
import 'usuario.dart';

class TelaBusca extends StatefulWidget {
  const TelaBusca({super.key});

  @override
  State<TelaBusca> createState() => _TelaBuscaState();
}

class _TelaBuscaState extends State<TelaBusca> {
  final _controller = TextEditingController();
  Future<ResultadoBusca>? _resultadoFuturo;

  void _buscar() {
    final termo = _controller.text.trim();
    if (termo.isEmpty) return;
    setState(() {
      _resultadoFuturo = buscaGeral(termo);
    });
  }

  void _abrirPerfil(Usuario usuario) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TelaPerfilUsuario(usuarioId: usuario.id),
    ));
  }

  void _abrirPostagem(Postagem postagem) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Postagem')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: CartaoPostagem(postagem: postagem),
        ),
      ),
    ));
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Buscar usuário ou postagem',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _buscar(),
                ),
              ),
              IconButton(
                onPressed: _buscar,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _resultado()),
        ],
      ),
    );
  }

  Widget _resultado() {
    final resultadoFuturo = _resultadoFuturo;
    if (resultadoFuturo == null) {
      return const Center(child: Text('Digite um termo para buscar'));
    }
    return FutureBuilder<ResultadoBusca>(
      future: resultadoFuturo,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Buscando...'));
        }

        final resultado = snapshot.data!;
        if (resultado.usuarios.isEmpty && resultado.postagens.isEmpty) {
          return const Center(child: Text('Nada encontrado'));
        }

        return ListView(
          children: [
            if (resultado.usuarios.isNotEmpty) ...[
              const Text('Usuários',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              for (final usuario in resultado.usuarios)
                CartaoUsuario(
                  usuario: usuario,
                  aoTocar: () => _abrirPerfil(usuario),
                ),
              const Divider(),
            ],
            if (resultado.postagens.isNotEmpty) ...[
              const Text('Postagens',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              for (final postagem in resultado.postagens)
                ListTile(
                  title: Text(
                    postagem.texto,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                      'Por ${postagem.autor ?? 'desconhecido'} • ${postagem.curtidas} curtidas'),
                  onTap: () => _abrirPostagem(postagem),
                ),
            ],
          ],
        );
      },
    );
  }
}
