import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

class Atividade {
  final int id;
  final DateTime dia;
  final String titulo;
  final String? descricao;

  const Atividade({
    required this.id,
    required this.dia,
    required this.titulo,
    required this.descricao,
  });

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: int.parse('${json['id']}'),
      dia: DateTime.parse(json['dia'] as String), // vem como aaaa-mm-dd
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
    );
  }
}

// listaAtividades.php devolve as atividades do mês em um array JSON
Future<List<Atividade>> buscaAtividades(int mes, int ano) async {
  final resposta = await http.get(
    Uri.http(servidor, '/listaAtividades.php', {'mes': '$mes', 'ano': '$ano'}),
    headers: {'Accept': 'application/json'},
  );

  if (resposta.statusCode != 200) {
    throw 'Falha ao carregar as atividades.';
  }
  final lista = jsonDecode(resposta.body) as List<dynamic>;
  return [
    for (final item in lista) Atividade.fromJson(item as Map<String, dynamic>)
  ];
}

// Os PHPs de gravação respondem com texto: "Atividade ..." quando dá certo
// ou "Erro -> motivo" quando não dá.
Future<String> _envia(String arquivo, Map<String, String> campos) async {
  final resposta = await http.post(Uri.http(servidor, '/$arquivo'), body: campos);
  final texto = resposta.body.trim();

  if (resposta.statusCode == 200 && texto.startsWith('Atividade')) {
    return texto;
  }
  if (texto.startsWith('Erro ->')) {
    throw texto.substring('Erro ->'.length).trim();
  }
  throw 'Erro no servidor!';
}

Future<String> salvaAtividade(DateTime dia, String titulo, String descricao) {
  return _envia('salvaAtividade.php', {
    'dia': dataParaApi(dia),
    'titulo': titulo,
    'descricao': descricao,
  });
}

Future<String> editaAtividade(
    int id, DateTime dia, String titulo, String descricao) {
  return _envia('editaAtividade.php', {
    'id': '$id',
    'dia': dataParaApi(dia),
    'titulo': titulo,
    'descricao': descricao,
  });
}

Future<String> excluiAtividade(int id) {
  return _envia('excluiAtividade.php', {'id': '$id'});
}

// Junta as atividades do mesmo dia, mantendo a ordem que veio do servidor.
Map<DateTime, List<Atividade>> agrupaPorDia(List<Atividade> lista) {
  final grupos = <DateTime, List<Atividade>>{};
  for (final atividade in lista) {
    grupos.putIfAbsent(atividade.dia, () => []).add(atividade);
  }
  return grupos;
}
