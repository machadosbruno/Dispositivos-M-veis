import 'package:flutter/material.dart';

import 'cartao_usuario.dart';
import 'usuario.dart';

class TelaUsuarios extends StatefulWidget {
  const TelaUsuarios({super.key});

  @override
  State<TelaUsuarios> createState() => _TelaUsuariosState();
}

class _TelaUsuariosState extends State<TelaUsuarios> {
  late Future<List<Usuario>> _usuariosFuturo;

  @override
  void initState() {
    super.initState();
    _usuariosFuturo = buscaUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<Usuario>>(
        future: _usuariosFuturo,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Carregando...'));
          }

          final lista = snapshot.data!;
          if (lista.isEmpty) {
            return const Center(child: Text('Nenhum outro usuário'));
          }

          return ListView.separated(
            itemCount: lista.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) =>
                CartaoUsuario(usuario: lista[index]),
          );
        },
      ),
    );
  }
}
