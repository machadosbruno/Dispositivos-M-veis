import 'package:flutter/material.dart';

import 'amizade.dart';

class TelaAmizades extends StatefulWidget {
  const TelaAmizades({super.key});

  @override
  State<TelaAmizades> createState() => _TelaAmizadesState();
}

class _TelaAmizadesState extends State<TelaAmizades> {
  late Future<List<Solicitacao>> _solicitacoesFuturo;

  @override
  void initState() {
    super.initState();
    _atualizar();
  }

  void _atualizar() {
    setState(() {
      _solicitacoesFuturo = buscaSolicitacoes();
    });
  }

  Future<void> _responder(Solicitacao solicitacao, bool aceitar) async {
    try {
      await respondeSolicitacao(solicitacao.id, aceitar: aceitar);
      _atualizar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<Solicitacao>>(
        future: _solicitacoesFuturo,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Carregando...'));
          }

          final lista = snapshot.data!;
          if (lista.isEmpty) {
            return const Center(child: Text('Nenhuma solicitação pendente'));
          }

          return ListView.separated(
            itemCount: lista.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final solicitacao = lista[index];
              return ListTile(
                title: Text(solicitacao.solicitanteNome ?? 'Usuário'),
                subtitle: const Text('Quer ser seu amigo'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _responder(solicitacao, true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _responder(solicitacao, false),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
