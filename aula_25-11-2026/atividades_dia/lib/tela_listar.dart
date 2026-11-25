import 'package:flutter/material.dart';

import 'atividade.dart';
import 'config.dart';
import 'tela_editar.dart';

class TelaListar extends StatefulWidget {
  const TelaListar({super.key});

  @override
  State<TelaListar> createState() => _TelaListarState();
}

class _TelaListarState extends State<TelaListar> {
  late int _mes;
  late int _ano;
  late Future<List<Atividade>> _atividadesFuturo;

  @override
  void initState() {
    super.initState();
    final agora = hoje();
    _mes = agora.month;
    _ano = agora.year;
    _atividadesFuturo = buscaAtividades(_mes, _ano);
  }

  void _atualizar() {
    setState(() {
      _atividadesFuturo = buscaAtividades(_mes, _ano);
    });
  }

  void _trocarMes(int mes, int ano) {
    setState(() {
      _mes = mes;
      _ano = ano;
      _atividadesFuturo = buscaAtividades(_mes, _ano);
    });
  }

  Future<void> _editar(Atividade atividade) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => TelaEditar(atividade: atividade)),
    );
    if (!mounted) return;
    if (alterou == true) _atualizar();
  }

  Future<void> _excluir(Atividade atividade) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir atividade'),
        content: Text('Deseja excluir "${atividade.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    String mensagem;
    try {
      mensagem = await excluiAtividade(atividade.id);
    } catch (e) {
      mensagem = e is String ? e : 'Falha na conexão: $e';
    }
    if (!mounted) return;
    _atualizar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anoAtual = hoje().year;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  key: const Key('lista-mes-dropdown'),
                  isExpanded: true,
                  value: _mes,
                  items: [
                    for (var mes = 1; mes <= 12; mes++)
                      DropdownMenuItem(
                        value: mes,
                        child: Text(nomesMeses[mes - 1]),
                      ),
                  ],
                  onChanged: (mes) {
                    if (mes != null) _trocarMes(mes, _ano);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<int>(
                  key: const Key('lista-ano-dropdown'),
                  isExpanded: true,
                  value: _ano,
                  items: [
                    for (var ano = anoAtual; ano >= 2000; ano--)
                      DropdownMenuItem(value: ano, child: Text('$ano')),
                  ],
                  onChanged: (ano) {
                    if (ano != null) _trocarMes(_mes, ano);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Atividade>>(
              future: _atividadesFuturo,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: Text('Carregando...'));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }

                final lista = snapshot.data!;
                if (lista.isEmpty) {
                  return const Center(child: Text('Nenhuma atividade neste mês'));
                }

                final grupos = agrupaPorDia(lista);
                return ListView(
                  children: [
                    for (final grupo in grupos.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          dataParaTela(grupo.key),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      for (final atividade in grupo.value)
                        ListTile(
                          title: Text(atividade.titulo),
                          subtitle: atividade.descricao == null
                              ? null
                              : Text(atividade.descricao!),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                key: ValueKey('lista-editar-${atividade.id}'),
                                icon: const Icon(Icons.edit),
                                tooltip: 'Editar',
                                onPressed: () => _editar(atividade),
                              ),
                              IconButton(
                                key: ValueKey('lista-excluir-${atividade.id}'),
                                icon: const Icon(Icons.delete),
                                tooltip: 'Excluir',
                                onPressed: () => _excluir(atividade),
                              ),
                            ],
                          ),
                        ),
                      const Divider(),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            key: const Key('lista-atualizar-botao'),
            onPressed: _atualizar,
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }
}
