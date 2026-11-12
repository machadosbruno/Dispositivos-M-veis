import 'package:flutter/material.dart';

import 'tela_amizades.dart';
import 'tela_busca.dart';
import 'tela_inserir.dart';
import 'tela_listar.dart';
import 'tela_usuarios.dart';

class TelaHome extends StatelessWidget {
  final Future<void> Function() aoSair;

  const TelaHome({super.key, required this.aoSair});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // quantidade de abas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fotos e textos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: aoSair,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add_a_photo)),
              Tab(icon: Icon(Icons.photo_library)),
              Tab(icon: Icon(Icons.people)),
              Tab(icon: Icon(Icons.person_search)),
              Tab(icon: Icon(Icons.search)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TelaInserir(),
            TelaListar(),
            TelaAmizades(),
            TelaUsuarios(),
            TelaBusca(),
          ],
        ),
      ),
    );
  }
}
