import 'dart:io';

import 'package:caes_com_janelas/helper.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadastro de pets',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const CadastroPetsPage(),
    );
  }
}

class CadastroPetsPage extends StatefulWidget {
  const CadastroPetsPage({super.key});

  @override
  State<CadastroPetsPage> createState() => _CadastroPetsPageState();
}

class _CadastroPetsPageState extends State<CadastroPetsPage> {
  final _salvarFormKey = GlobalKey<FormState>();
  final _atualizarFormKey = GlobalKey<FormState>();
  final _apagarFormKey = GlobalKey<FormState>();
  final _salvarNomeController = TextEditingController();
  final _salvarIdadeController = TextEditingController();
  final _atualizarIdController = TextEditingController();
  final _atualizarNomeController = TextEditingController();
  final _atualizarIdadeController = TextEditingController();
  final _apagarIdController = TextEditingController();

  late Future<List<Map<String, dynamic>>> _petsFuture;
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    _petsFuture = DatabaseHelper.buscarTodos();
  }

  @override
  void dispose() {
    _salvarNomeController.dispose();
    _salvarIdadeController.dispose();
    _atualizarIdController.dispose();
    _atualizarNomeController.dispose();
    _atualizarIdadeController.dispose();
    _apagarIdController.dispose();
    super.dispose();
  }

  Future<void> _executarOperacao(
    Future<String> Function() operacao, {
    VoidCallback? aoConcluir,
  }) async {
    setState(() => _ocupado = true);
    try {
      final mensagem = await operacao();
      if (!mounted) return;
      aoConcluir?.call();
      setState(() {
        _petsFuture = DatabaseHelper.buscarTodos();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível concluir a operação: $erro')),
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  String? _validarTextoObrigatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Preencha este campo.';
    }
    return null;
  }

  String? _validarNumeroInteiro(String? valor) {
    if (valor == null || int.tryParse(valor.trim()) == null) {
      return 'Informe um número inteiro válido.';
    }
    if (int.parse(valor.trim()) < 0) {
      return 'O valor não pode ser negativo.';
    }
    return null;
  }

  String? _validarId(String? valor) {
    final validacao = _validarNumeroInteiro(valor);
    if (validacao != null) return validacao;
    if (int.parse(valor!.trim()) < 1) return 'Informe um ID válido.';
    return null;
  }

  Future<void> _salvarPet() async {
    if (!_salvarFormKey.currentState!.validate()) return;

    final nome = _salvarNomeController.text.trim();
    final idade = int.parse(_salvarIdadeController.text.trim());
    await _executarOperacao(
      () async {
        await DatabaseHelper.inserirCao({'nome': nome, 'idade': idade});
        return '$nome foi salvo com sucesso.';
      },
      aoConcluir: () {
        _salvarNomeController.clear();
        _salvarIdadeController.clear();
      },
    );
  }

  Future<void> _atualizarPet() async {
    if (!_atualizarFormKey.currentState!.validate()) return;

    final id = int.parse(_atualizarIdController.text.trim());
    final nome = _atualizarNomeController.text.trim();
    final idade = int.parse(_atualizarIdadeController.text.trim());
    await _executarOperacao(
      () async {
        final linhasAlteradas = await DatabaseHelper.atualizarCao(
          id,
          {'nome': nome, 'idade': idade},
        );
        return linhasAlteradas == 0
            ? 'Nenhum pet encontrado com o ID $id.'
            : 'Pet atualizado com sucesso.';
      },
      aoConcluir: () {
        _atualizarIdController.clear();
        _atualizarNomeController.clear();
        _atualizarIdadeController.clear();
      },
    );
  }

  Future<void> _apagarPet() async {
    if (!_apagarFormKey.currentState!.validate()) return;

    final id = int.parse(_apagarIdController.text.trim());
    await _executarOperacao(
      () async {
        final linhasApagadas = await DatabaseHelper.apagarCao(id);
        return linhasApagadas == 0
            ? 'Nenhum pet encontrado com o ID $id.'
            : 'Pet apagado com sucesso.';
      },
      aoConcluir: _apagarIdController.clear,
    );
  }

  InputDecoration _decoracaoCampo(String rotulo) {
    return InputDecoration(
      labelText: rotulo,
      border: const OutlineInputBorder(),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String rotulo,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _decoracaoCampo(rotulo),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _botaoAcao(String texto, VoidCallback acao) {
    return FilledButton(
      onPressed: _ocupado ? null : acao,
      child: _ocupado
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(texto),
    );
  }

  Widget _formulario({
    required GlobalKey<FormState> formKey,
    required List<Widget> campos,
    required String textoBotao,
    required VoidCallback aoEnviar,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...[
                  for (var i = 0; i < campos.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    campos[i],
                  ],
                ],
                const SizedBox(height: 24),
                _botaoAcao(textoBotao, aoEnviar),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listarPets() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _petsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar os pets: ${snapshot.error}'),
          );
        }

        final pets = snapshot.data ?? [];
        if (pets.isEmpty) {
          return const Center(child: Text('Nenhum pet cadastrado.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: pets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final pet = pets[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${pet['id']}')),
                title: Text('${pet['nome']}'),
                subtitle: Text('Idade: ${pet['idade']}'),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cadastro de pets'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.add), text: 'Salvar'),
              Tab(icon: Icon(Icons.list), text: 'Listar'),
              Tab(icon: Icon(Icons.edit), text: 'Atualizar'),
              Tab(icon: Icon(Icons.delete), text: 'Apagar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _formulario(
              formKey: _salvarFormKey,
              campos: [
                _campoTexto(
                  controller: _salvarNomeController,
                  rotulo: 'Nome do pet',
                  validator: _validarTextoObrigatorio,
                ),
                _campoTexto(
                  controller: _salvarIdadeController,
                  rotulo: 'Idade do pet',
                  validator: _validarNumeroInteiro,
                  keyboardType: TextInputType.number,
                ),
              ],
              textoBotao: 'Salvar pet',
              aoEnviar: _salvarPet,
            ),
            _listarPets(),
            _formulario(
              formKey: _atualizarFormKey,
              campos: [
                _campoTexto(
                  controller: _atualizarIdController,
                  rotulo: 'ID do pet',
                  validator: _validarId,
                  keyboardType: TextInputType.number,
                ),
                _campoTexto(
                  controller: _atualizarNomeController,
                  rotulo: 'Novo nome',
                  validator: _validarTextoObrigatorio,
                ),
                _campoTexto(
                  controller: _atualizarIdadeController,
                  rotulo: 'Nova idade',
                  validator: _validarNumeroInteiro,
                  keyboardType: TextInputType.number,
                ),
              ],
              textoBotao: 'Atualizar pet',
              aoEnviar: _atualizarPet,
            ),
            _formulario(
              formKey: _apagarFormKey,
              campos: [
                _campoTexto(
                  controller: _apagarIdController,
                  rotulo: 'ID do pet',
                  validator: _validarId,
                  keyboardType: TextInputType.number,
                ),
              ],
              textoBotao: 'Apagar pet',
              aoEnviar: _apagarPet,
            ),
          ],
        ),
      ),
    );
  }
}
