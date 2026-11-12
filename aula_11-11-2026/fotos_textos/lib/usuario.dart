import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

class Usuario {
  final int id;
  final String nome;
  final String statusAmizade; // NENHUM, PENDENTE, ACEITO ou REJEITADO
  final bool pedidoMeu; // se o pedido PENDENTE foi enviado por mim

  const Usuario({
    required this.id,
    required this.nome,
    required this.statusAmizade,
    required this.pedidoMeu,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: int.parse('${json['id']}'),
      nome: json['nome'] as String,
      statusAmizade: json['status_amizade'] as String,
      pedidoMeu: paraBool(json['pedido_meu']),
    );
  }
}

// listaUsuarios.php devolve todos os usuários (exceto o logado) com o status
// da amizade entre eles
Future<List<Usuario>> buscaUsuarios() async {
  final usuarioId = await usuarioLogado();
  final resposta = await http.get(
    Uri.http(servidor, '/listaUsuarios.php', {'usuario_id': '$usuarioId'}),
  );

  if (resposta.statusCode != 200) {
    throw 'Falha ao carregar os usuários.';
  }
  final lista = jsonDecode(resposta.body) as List<dynamic>;
  return [
    for (final item in lista) Usuario.fromJson(item as Map<String, dynamic>)
  ];
}
