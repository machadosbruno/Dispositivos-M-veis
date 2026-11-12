import 'package:shared_preferences/shared_preferences.dart';

// endereço do servidor (XAMPP)
const servidor = '10.106.76.12';

// id do usuário salvo no shared_preferences ao fazer login/cadastro
Future<int> usuarioLogado() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('usuario_id') ?? 0;
}

bool paraBool(dynamic valor) => valor == true || valor == 1 || valor == '1';
