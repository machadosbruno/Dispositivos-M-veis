import 'package:flutter/material.dart';

import 'atividade.dart';
import 'formulario_atividade.dart';

// Aberta pela lista do mês; devolve true quando a atividade foi alterada.
class TelaEditar extends StatelessWidget {
  final Atividade atividade;

  const TelaEditar({super.key, required this.atividade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar atividade')),
      body: FormularioAtividade(
        atividade: atividade,
        aoSalvar: () => Navigator.pop(context, true),
      ),
    );
  }
}
