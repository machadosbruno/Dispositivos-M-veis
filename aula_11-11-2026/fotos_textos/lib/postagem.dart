import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

class Postagem {
  final int id;
  final int usuarioId;
  final String? autor;
  final String texto;
  final String? caminho;
  final int curtidas;
  final bool curtidaDoUsuario;
  final bool podeComentar;

  const Postagem({
    required this.id,
    required this.usuarioId,
    required this.autor,
    required this.texto,
    required this.caminho,
    required this.curtidas,
    required this.curtidaDoUsuario,
    required this.podeComentar,
  });

  factory Postagem.fromJson(Map<String, dynamic> json) {
    return Postagem(
      id: int.parse('${json['id']}'),
      usuarioId: int.parse('${json['usuario_id']}'),
      autor: json['autor'] as String?,
      texto: json['texto'] as String,
      caminho: json['caminho'] as String?,
      curtidas: int.parse('${json['curtidas']}'),
      curtidaDoUsuario: paraBool(json['curtida_do_usuario']),
      podeComentar: paraBool(json['pode_comentar']),
    );
  }
}

// listaPostagens.php devolve todas as postagens em um array JSON
Future<List<Postagem>> buscaPostagens() async {
  final usuarioId = await usuarioLogado();
  final resposta = await http.get(
    Uri.http(servidor, '/listaPostagens.php', {'usuario_id': '$usuarioId'}),
    headers: {'Accept': 'application/json'},
  );

  if (resposta.statusCode != 200) {
    throw 'Falha ao carregar as postagens.';
  }
  final lista = jsonDecode(resposta.body) as List<dynamic>;
  return [
    for (final item in lista) Postagem.fromJson(item as Map<String, dynamic>)
  ];
}

// curtirPostagem.php alterna curtir/descurtir e devolve o novo estado
Future<({bool curtidaDoUsuario, int curtidas})> curtirPostagem(
    int postagemId) async {
  final usuarioId = await usuarioLogado();
  final resposta = await http.get(Uri.http(servidor, '/curtirPostagem.php', {
    'postagem_id': '$postagemId',
    'usuario_id': '$usuarioId',
  }));

  if (resposta.statusCode != 200) {
    throw 'Falha ao curtir a postagem.';
  }
  final corpo = jsonDecode(resposta.body) as Map<String, dynamic>;
  return (
    curtidaDoUsuario: paraBool(corpo['curtida_do_usuario']),
    curtidas: int.parse('${corpo['curtidas']}'),
  );
}
