import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// IP do PC onde roda o XAMPP (api.php direto na htdocs)
const api = 'http://10.106.76.19/api.php';

int usuarioId = 0; // usuário logado (salvo em shared_preferences)
String perfil = ''; // produtor, vendedor ou gerente

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool carregou = false;

  @override
  void initState() {
    super.initState();
    carregaLogin();
  }

  void carregaLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioId = prefs.getInt('usuario_id') ?? 0;
      perfil = prefs.getString('perfil') ?? '';
      carregou = true;
    });
  }

  void sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      usuarioId = 0;
      perfil = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!carregou) {
      return const MaterialApp(home: Scaffold(body: Text('Carregando...')));
    }
    Widget janela = Entrar(aoEntrar: carregaLogin);
    if (perfil == 'produtor') janela = Produtor(aoSair: sair);
    if (perfil == 'vendedor') janela = Vendedor(aoSair: sair);
    if (perfil == 'gerente') janela = Gerente(aoSair: sair);
    return MaterialApp(home: janela);
  }
}

// Janela inicial: login ou cadastro
class Entrar extends StatefulWidget {
  const Entrar({super.key, required this.aoEntrar});

  final VoidCallback aoEntrar;

  @override
  State<Entrar> createState() => _EntrarState();
}

class _EntrarState extends State<Entrar> {
  TextEditingController nome = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController senha = TextEditingController();
  String perfilEscolhido = 'produtor';
  String mensagem = '';

  void enviar(String acao) async {
    final r = await http.post(Uri.parse('$api?acao=$acao'), body: {
      'nome': nome.text,
      'email': email.text,
      'senha': senha.text,
      'perfil': perfilEscolhido,
    });
    final dados = jsonDecode(r.body);
    if (r.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('usuario_id', dados['id']);
      await prefs.setString('perfil', dados['perfil']);
      widget.aoEntrar();
    } else {
      setState(() {
        mensagem = dados['erro'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: nome,
            decoration: const InputDecoration(hintText: 'Nome (só no cadastro)'),
          ),
          TextField(
            controller: email,
            decoration: const InputDecoration(hintText: 'E-mail'),
          ),
          TextField(
            controller: senha,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Senha'),
          ),
          DropdownButton<String>(
            value: perfilEscolhido,
            items: const [
              DropdownMenuItem(value: 'produtor', child: Text('Produtor')),
              DropdownMenuItem(value: 'vendedor', child: Text('Vendedor')),
            ],
            onChanged: (valor) {
              setState(() {
                perfilEscolhido = valor!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () => enviar('login'),
            child: const Text('Login'),
          ),
          ElevatedButton(
            onPressed: () => enviar('cadastro'),
            child: const Text('Cadastrar'),
          ),
          Text(mensagem),
        ],
      ),
    );
  }
}

// Janela do produtor: registra a produção
class Produtor extends StatefulWidget {
  const Produtor({super.key, required this.aoSair});

  final VoidCallback aoSair;

  @override
  State<Produtor> createState() => _ProdutorState();
}

class _ProdutorState extends State<Produtor> {
  TextEditingController quantidade = TextEditingController();
  TextEditingController valor = TextEditingController();
  double comissao = 0;
  String resultado = '';

  @override
  void initState() {
    super.initState();
    buscaComissao();
  }

  void buscaComissao() async {
    final r = await http.get(Uri.parse('$api?acao=comissao'));
    setState(() {
      comissao = double.parse('${jsonDecode(r.body)['comissao']}');
    });
  }

  void registrar() async {
    final r = await http.post(Uri.parse('$api?acao=produzir'), body: {
      'usuario_id': '$usuarioId',
      'quantidade': quantidade.text,
      'valor_unitario': valor.text.replaceAll(',', '.'),
    });
    final dados = jsonDecode(r.body);
    setState(() {
      if (r.statusCode == 200) {
        resultado = 'Total antes da comissão: R\$ ${dados['total_antes']}\n'
            'Total depois da comissão: R\$ ${dados['total_depois']}';
      } else {
        resultado = dados['erro'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtor'),
        actions: [
          TextButton(onPressed: widget.aoSair, child: const Text('Sair')),
        ],
      ),
      body: Column(
        children: [
          Text('Comissão atual do sistema: $comissao%'),
          TextField(
            controller: quantidade,
            decoration: const InputDecoration(hintText: 'Quantidade de trufas'),
          ),
          TextField(
            controller: valor,
            decoration: const InputDecoration(hintText: 'Valor unitário'),
          ),
          ElevatedButton(onPressed: registrar, child: const Text('Registrar')),
          Text(resultado),
        ],
      ),
    );
  }
}

// Janela do vendedor: lista produções e compra
class Vendedor extends StatefulWidget {
  const Vendedor({super.key, required this.aoSair});

  final VoidCallback aoSair;

  @override
  State<Vendedor> createState() => _VendedorState();
}

class _VendedorState extends State<Vendedor> {
  List lista = [];
  final controladores = <int, TextEditingController>{};
  String resultado = '';

  @override
  void initState() {
    super.initState();
    carregar();
  }

  void carregar() async {
    final r = await http
        .get(Uri.parse('$api?acao=producoes&usuario_id=$usuarioId'));
    setState(() {
      lista = jsonDecode(r.body);
    });
  }

  void comprar(int id) async {
    final texto = controladores[id]?.text ?? '';
    final r = await http.post(Uri.parse('$api?acao=comprar'), body: {
      'usuario_id': '$usuarioId',
      'producao_id': '$id',
      'quantidade': texto,
    });
    final dados = jsonDecode(r.body);
    setState(() {
      if (r.statusCode == 200) {
        resultado = 'Compra: ${dados['quantidade']} x R\$ ${dados['valor_unitario']}\n'
            'Valor total: R\$ ${dados['valor_total']}\n'
            'Comissão (${dados['comissao']}%): R\$ ${dados['valor_comissao']}\n'
            'Valor para o produtor: R\$ ${dados['valor_produtor']}';
      } else {
        resultado = dados['erro'];
      }
    });
    carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendedor'),
        actions: [
          TextButton(onPressed: widget.aoSair, child: const Text('Sair')),
        ],
      ),
      body: Column(
        children: [
          Text(resultado),
          Expanded(
            child: ListView(
              children: [
                ...lista.map((p) {
                  final id = int.parse('${p['id']}');
                  controladores.putIfAbsent(id, () => TextEditingController());
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${p['produtor']} - estoque ${p['estoque']} - R\$ ${p['valor_unitario']}',
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextField(controller: controladores[id]),
                      ),
                      TextButton(
                        onPressed: () => comprar(id),
                        child: const Text('Comprar'),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Janela do gerente: totais, comissão e lucro do mês
class Gerente extends StatefulWidget {
  const Gerente({super.key, required this.aoSair});

  final VoidCallback aoSair;

  @override
  State<Gerente> createState() => _GerenteState();
}

class _GerenteState extends State<Gerente> {
  TextEditingController novaComissao = TextEditingController();
  Map resumo = {};
  String mensagem = '';

  @override
  void initState() {
    super.initState();
    carregar();
  }

  void carregar() async {
    final r = await http
        .get(Uri.parse('$api?acao=resumo&usuario_id=$usuarioId'));
    setState(() {
      resumo = jsonDecode(r.body);
    });
  }

  void ajustar() async {
    final r = await http.post(Uri.parse('$api?acao=definir_comissao'), body: {
      'usuario_id': '$usuarioId',
      'comissao': novaComissao.text.replaceAll(',', '.'),
    });
    setState(() {
      mensagem = r.statusCode == 200 ? 'Comissão atualizada' : jsonDecode(r.body)['erro'];
    });
    carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerente'),
        actions: [
          TextButton(onPressed: widget.aoSair, child: const Text('Sair')),
        ],
      ),
      body: Column(
        children: [
          Text('Trufas geradas: ${resumo['total_gerado'] ?? ''}'),
          Text('Trufas vendidas: ${resumo['total_vendido'] ?? ''}'),
          Text('Lucro do mês: R\$ ${resumo['lucro_mes'] ?? ''}'),
          Text('Comissão atual: ${resumo['comissao'] ?? ''}%'),
          TextField(
            controller: novaComissao,
            decoration: const InputDecoration(hintText: 'Novo percentual'),
          ),
          ElevatedButton(onPressed: ajustar, child: const Text('Ajustar comissão')),
          ElevatedButton(onPressed: carregar, child: const Text('Atualizar')),
          Text(mensagem),
        ],
      ),
    );
  }
}
