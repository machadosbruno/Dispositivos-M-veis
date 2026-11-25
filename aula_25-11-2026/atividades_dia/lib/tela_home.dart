import 'package:flutter/material.dart';

import 'tela_cadastrar.dart';
import 'tela_listar.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // quantidade de abas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Atividades do dia'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add), text: 'Cadastrar'),
              Tab(icon: Icon(Icons.calendar_month), text: 'Atividades do mês'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TelaCadastrar(),
            TelaListar(),
          ],
        ),
      ),
    );
  }
}
