import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

class PerfilUsuario {
  final int id;
  final String nome;
  final String statusAmizade; // NENHUM, PENDENTE, ACEITO ou REJEITADO
  final bool pedidoMeu;
  final int? solicitacaoId;

  const PerfilUsuario({
    required this.id,
    required this.nome,
    required this.statusAmizade,
    required this.pedidoMeu,
    required this.solicitacaoId,
  });

  factory PerfilUsuario.fromJson(Map<String, dynamic> json) {
    return PerfilUsuario(
      id: int.parse('${json['id']}'),
      nome: json['nome'] as String,
      statusAmizade: json['status_amizade'] as String,
      pedidoMeu: paraBool(json['pedido_meu']),
      solicitacaoId: json['solicitacao_id'] == null
          ? null
          : int.parse('${json['solicitacao_id']}'),
    );
  }
}

// perfilUsuario.php devolve o nome e o status de amizade com o usuário logado
Future<PerfilUsuario> buscaPerfilUsuario(int usuarioId) async {
  final usuarioAtual = await usuarioLogado();
  final resposta = await http.get(Uri.http(servidor, '/perfilUsuario.php', {
    'usuario_atual': '$usuarioAtual',
    'usuario_id': '$usuarioId',
  }));

  final corpo = jsonDecode(resposta.body) as Map<String, dynamic>;
  if (resposta.statusCode != 200 || corpo.containsKey('erro')) {
    throw corpo['erro'] as String? ?? 'Falha ao carregar o perfil.';
  }
  return PerfilUsuario.fromJson(corpo);
}
