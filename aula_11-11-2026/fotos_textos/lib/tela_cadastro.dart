import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

class TelaCadastro extends StatefulWidget {
  final VoidCallback aoEntrar;

  const TelaCadastro({super.key, required this.aoEntrar});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _modoLogin = false;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _preencherSessaoAnterior();
  }

  // Se já existir um e-mail de uma sessão anterior (ex.: após um logout),
  // a tela entra direto no modo login com o e-mail pré-preenchido.
  Future<void> _preencherSessaoAnterior() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('usuario_email');
    if (email == null || email.isEmpty) return;
    setState(() {
      _modoLogin = true;
      _emailController.text = email;
    });
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);

    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    String? erro;
    try {
      final endpoint = _modoLogin ? '/login_usuario.php' : '/salva_usuario.php';
      final parametros = {
        'email': email,
        'senha': senha,
        if (!_modoLogin) 'nome': nome,
      };

      final resposta =
          await http.get(Uri.http(servidor, endpoint, parametros));

      final corpo = jsonDecode(resposta.body) as Map<String, dynamic>;
      if (resposta.statusCode == 200 && corpo.containsKey('resposta')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('usuario_id', int.parse('${corpo['id']}'));
        await prefs.setString(
            'usuario_nome', _modoLogin ? '${corpo['nome']}' : nome);
        await prefs.setString('usuario_email', email);
        widget.aoEntrar();
        return;
      }
      erro = corpo['erro'] as String? ??
          (_modoLogin ? 'Erro no login!' : 'Erro no cadastro!');
    } catch (e) {
      erro = 'Falha na conexão: $e';
    }

    if (!mounted) return;
    setState(() => _enviando = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(erro)));
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_modoLogin ? 'Login' : 'Cadastro de usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_modoLogin) ...[
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) =>
                      (valor == null || valor.trim().isEmpty)
                          ? 'Informe o nome'
                          : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) =>
                    (valor == null || valor.trim().isEmpty)
                        ? 'Informe o e-mail'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                maxLength: 20,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => (valor == null || valor.isEmpty)
                    ? 'Informe a senha'
                    : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _enviando ? null : _entrar,
                child: _enviando
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_modoLogin ? 'Entrar' : 'Cadastrar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _enviando
                    ? null
                    : () => setState(() => _modoLogin = !_modoLogin),
                child: Text(_modoLogin
                    ? 'Não tem conta? Cadastre-se'
                    : 'Já tem conta? Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
