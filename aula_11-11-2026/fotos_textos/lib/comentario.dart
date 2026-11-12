import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

class Comentario {
  final int id;
  final String? autor;
  final String texto;

  const Comentario({required this.id, required this.autor, required this.texto});

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: int.parse('${json['id']}'),
      autor: json['autor'] as String?,
      texto: json['texto'] as String,
    );
  }
}

// listaComentarios.php só devolve a lista se o usuário puder ver (autor ou amigo)
Future<List<Comentario>> buscaComentarios(int postagemId) async {
  final usuarioId = await usuarioLogado();
  final resposta = await http.get(Uri.http(servidor, '/listaComentarios.php', {
    'postagem_id': '$postagemId',
    'usuario_id': '$usuarioId',
  }));

  if (resposta.statusCode != 200) {
    throw 'Falha ao carregar os comentários.';
  }
  final corpo = jsonDecode(resposta.body);
  if (corpo is Map<String, dynamic> && corpo.containsKey('erro')) {
    throw corpo['erro'] as String;
  }
  final lista = corpo as List<dynamic>;
  return [
    for (final item in lista) Comentario.fromJson(item as Map<String, dynamic>)
  ];
}

// salvaComentario.php só aceita se o usuário for o autor da postagem ou amigo dele
Future<void> salvaComentario(int postagemId, String texto) async {
  final usuarioId = await usuarioLogado();
  final resposta = await http.get(Uri.http(servidor, '/salvaComentario.php', {
    'postagem_id': '$postagemId',
    'usuario_id': '$usuarioId',
    'texto': texto,
  }));

  final corpo = jsonDecode(resposta.body) as Map<String, dynamic>;
  if (resposta.statusCode != 200 || corpo.containsKey('erro')) {
    throw corpo['erro'] as String? ?? 'Erro ao comentar.';
  }
}
