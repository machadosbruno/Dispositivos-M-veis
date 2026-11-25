import 'package:flutter/material.dart';

import 'atividade.dart';
import 'config.dart';

// Formulário usado para cadastrar (atividade == null) e para editar.
class FormularioAtividade extends StatefulWidget {
  final Atividade? atividade;
  final void Function()? aoSalvar;

  const FormularioAtividade({super.key, this.atividade, this.aoSalvar});

  @override
  State<FormularioAtividade> createState() => _FormularioAtividadeState();
}

class _FormularioAtividadeState extends State<FormularioAtividade> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  late DateTime _dia;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final atividade = widget.atividade;
    _dia = atividade?.dia ?? hoje();
    _tituloController.text = atividade?.titulo ?? '';
    _descricaoController.text = atividade?.descricao ?? '';
  }

  // só deixa escolher até hoje (não aceita datas futuras)
  Future<void> _escolherDia() async {
    final dia = await showDatePicker(
      context: context,
      initialDate: _dia,
      firstDate: DateTime(2000),
      lastDate: hoje(),
      helpText: 'Dia da atividade',
      cancelText: 'Cancelar',
      confirmText: 'OK',
      fieldLabelText: 'Data',
      fieldHintText: 'mm/dd/aaaa',
      errorFormatText: 'Data inválida',
      errorInvalidText: 'Escolha uma data até hoje',
    );
    if (dia == null) return; // usuário cancelou
    setState(() {
      _dia = dia;
    });
  }

  Future<void> _salvar() async {
    final titulo = _tituloController.text.trim();
    final descricao = _descricaoController.text.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o título da atividade')),
      );
      return;
    }

    setState(() => _salvando = true);
    final atividade = widget.atividade;
    String mensagem;
    bool salvou = false;
    try {
      mensagem = atividade == null
          ? await salvaAtividade(_dia, titulo, descricao)
          : await editaAtividade(atividade.id, _dia, titulo, descricao);
      salvou = true;
    } catch (e) {
      mensagem = e is String ? e : 'Falha na conexão: $e';
    }

    if (!mounted) return; // a tela pode ter sido fechada durante a espera
    setState(() {
      _salvando = false;
      if (salvou && atividade == null) {
        // cadastro: deixa o formulário pronto para a próxima atividade
        _tituloController.clear();
        _descricaoController.clear();
        _dia = hoje();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
    if (salvou) widget.aoSalvar?.call();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Dia: ${dataParaTela(_dia)}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          key: const Key('formulario-dia-botao'),
          onPressed: _escolherDia,
          child: const Text('Escolher dia'),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('formulario-titulo-campo'),
          controller: _tituloController,
          maxLength: 100,
          decoration: const InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('formulario-descricao-campo'),
          controller: _descricaoController,
          maxLength: 200,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Descrição',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          key: const Key('formulario-salvar-botao'),
          onPressed: _salvando ? null : _salvar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
