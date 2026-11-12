import 'package:flutter/material.dart';

import 'amizade.dart';
import 'usuario.dart';

// Mostra um usuário e o botão de amizade de acordo com o status atual entre
// ele e o usuário logado.
class CartaoUsuario extends StatefulWidget {
  final Usuario usuario;
  final VoidCallback? aoTocar;

  const CartaoUsuario({super.key, required this.usuario, this.aoTocar});

  @override
  State<CartaoUsuario> createState() => _CartaoUsuarioState();
}

class _CartaoUsuarioState extends State<CartaoUsuario> {
  late String _status;
  late bool _pedidoMeu;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _status = widget.usuario.statusAmizade;
    _pedidoMeu = widget.usuario.pedidoMeu;
  }

  Future<void> _solicitar() async {
    setState(() => _enviando = true);
    try {
      await solicitaAmizade(widget.usuario.id);
      setState(() {
        _status = 'PENDENTE';
        _pedidoMeu = true;
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
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.usuario.nome),
      trailing: _botao(),
      onTap: widget.aoTocar,
    );
  }

  Widget _botao() {
    if (_status == 'ACEITO') {
      return const Text('Amigos');
    }
    if (_status == 'PENDENTE') {
      return Text(_pedidoMeu ? 'Pedido enviado' : 'Aguardando você');
    }
    return ElevatedButton(
      onPressed: _enviando ? null : _solicitar,
      child: const Text('Solicitar amizade'),
    );
  }
}
