import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

class Solicitacao {
  final int id;
  final int solicitanteId;
  final String? solicitanteNome;

  const Solicitacao({
    required this.id,
    required this.solicitanteId,
    required this.solicitanteNome,
  });

  factory Solicitacao.fromJson(Map<String, dynamic> json) {
    return Solicitacao(
      id: int.parse('${json['id']}'),
      solicitanteId: int.parse('${json['solicitante_id']}'),
      solicitanteNome: json['solicitante_nome'] as String?,
    );
  }
}

// solicitaAmizade.php cria o pedido (ou reabre um que tinha sido rejeitado)
Future<void> solicitaAmizade(int solicitadoId) async {
  final usuarioId = await usuarioLogado();
  final resposta = await http.get(Uri.http(servidor, '/solicitaAmizade.php', {
    'solicitante_id': '$usuarioId',
    'solicitado_id': '$solicitadoId',
  }));

  final corpo = jsonDecode(resposta.body) as Map<String, dynamic>;
  if (resposta.statusCode != 200 || corpo.containsKey('erro')) {
    throw corpo['erro'] as String? ?? 'Erro ao solicitar amizade.';
  }
}

// listaSolicitacoes.php devolve os pedidos pendentes recebidos pelo usuário logado
Future<List<Solicitacao>> buscaSolicitacoes() async {
  final usuarioId = await usuarioLogado();
  final resposta = await http.get(
    Uri.http(servidor, '/listaSolicitacoes.php', {'usuario_id': '$usuarioId'}),
  );

  if (resposta.statusCode != 200) {
    throw 'Falha ao carregar as solicitações.';
  }
  final lista = jsonDecode(resposta.body) as List<dynamic>;
  return [
    for (final item in lista)
      Solicitacao.fromJson(item as Map<String, dynamic>)
  ];
}

// respondeSolicitacao.php aceita ou rejeita um pedido de amizade
Future<void> respondeSolicitacao(int id, {required bool aceitar}) async {
  final resposta = await http.get(
    Uri.http(servidor, '/respondeSolicitacao.php', {
      'id': '$id',
      'status': aceitar ? 'ACEITO' : 'REJEITADO',
    }),
  );

  final corpo = jsonDecode(resposta.body) as Map<String, dynamic>;
  if (resposta.statusCode != 200 || corpo.containsKey('erro')) {
    throw corpo['erro'] as String? ?? 'Erro ao responder solicitação.';
  }
}
