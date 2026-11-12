import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'postagem.dart';
import 'usuario.dart';

class ResultadoBusca {
  final List<Usuario> usuarios;
  final List<Postagem> postagens;

  const ResultadoBusca({required this.usuarios, required this.postagens});
}

// buscaGeral.php devolve usuários e postagens cujo nome/texto combina com o termo
Future<ResultadoBusca> buscaGeral(String termo) async {
  final usuarioId = await usuarioLogado();
  final resposta = await http.get(Uri.http(servidor, '/buscaGeral.php', {
    'usuario_id': '$usuarioId',
    'termo': termo,
  }));

  if (resposta.statusCode != 200) {
    throw 'Falha ao buscar.';
  }
  final corpo = jsonDecode(resposta.body) as Map<String, dynamic>;
  final usuarios = corpo['usuarios'] as List<dynamic>;
  final postagens = corpo['postagens'] as List<dynamic>;
  return ResultadoBusca(
    usuarios: [
      for (final item in usuarios)
        Usuario.fromJson(item as Map<String, dynamic>)
    ],
    postagens: [
      for (final item in postagens)
        Postagem.fromJson(item as Map<String, dynamic>)
    ],
  );
}
