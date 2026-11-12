import 'package:flutter/material.dart';

import 'cartao_postagem.dart';
import 'postagem.dart';

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
                child: CartaoPostagem(
                  key: ValueKey(postagem.id), // força recarregar ao trocar
                  postagem: postagem,
                ),
              ),
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
