import 'package:flutter/material.dart';

import 'amizade.dart';
import 'perfil_usuario.dart';

class TelaPerfilUsuario extends StatefulWidget {
  final int usuarioId;

  const TelaPerfilUsuario({super.key, required this.usuarioId});

  @override
  State<TelaPerfilUsuario> createState() => _TelaPerfilUsuarioState();
}

class _TelaPerfilUsuarioState extends State<TelaPerfilUsuario> {
  late Future<PerfilUsuario> _perfilFuturo;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _atualizar();
  }

  void _atualizar() {
    setState(() {
      _perfilFuturo = buscaPerfilUsuario(widget.usuarioId);
    });
  }

  Future<void> _solicitar() async {
    setState(() => _enviando = true);
    try {
      await solicitaAmizade(widget.usuarioId);
      _atualizar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _responder(int solicitacaoId, bool aceitar) async {
    setState(() => _enviando = true);
    try {
      await respondeSolicitacao(solicitacaoId, aceitar: aceitar);
      _atualizar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<PerfilUsuario>(
          future: _perfilFuturo,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('Carregando...'));
            }

            final perfil = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(perfil.nome,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                _status(perfil),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _status(PerfilUsuario perfil) {
    if (perfil.statusAmizade == 'ACEITO') {
      return const Text('Vocês são amigos');
    }

    if (perfil.statusAmizade == 'PENDENTE') {
      if (perfil.pedidoMeu) {
        return const Text('Pedido de amizade enviado');
      }
      return Column(
        children: [
          const Text('Quer ser seu amigo'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _enviando
                    ? null
                    : () => _responder(perfil.solicitacaoId!, true),
                child: const Text('Aceitar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _enviando
                    ? null
                    : () => _responder(perfil.solicitacaoId!, false),
                child: const Text('Rejeitar'),
              ),
            ],
          ),
        ],
      );
    }

    return ElevatedButton(
      onPressed: _enviando ? null : _solicitar,
      child: const Text('Solicitar amizade'),
    );
  }
}
