import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tela_cadastro.dart';
import 'tela_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TelaInicial(),
    );
  }
}

// Decide entre mostrar o cadastro ou a tela principal, conforme o que já
// estiver salvo no shared_preferences.
class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  late Future<bool> _usuarioCadastrado;

  @override
  void initState() {
    super.initState();
    _usuarioCadastrado = _verificaUsuario();
  }

  Future<bool> _verificaUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('usuario_id');
  }

  void _aoEntrar() {
    setState(() {
      _usuarioCadastrado = Future.value(true);
    });
  }

  // Mantém o e-mail salvo para a tela de cadastro já abrir no modo login.
  Future<void> _aoSair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_id');
    setState(() {
      _usuarioCadastrado = Future.value(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _usuarioCadastrado,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!
            ? TelaHome(aoSair: _aoSair)
            : TelaCadastro(aoEntrar: _aoEntrar);
      },
    );
  }
}
