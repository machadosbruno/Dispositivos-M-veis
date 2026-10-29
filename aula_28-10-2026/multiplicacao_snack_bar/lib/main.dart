import 'dart:math';

import 'package:flutter/material.dart';
import 'package:multiplicacao_snack_bar/questoes.dart';

void main() {
  runApp(const MultiplicacaoApp());
}

class MultiplicacaoApp extends StatelessWidget {
  const MultiplicacaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz de multiplicação',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Controle(),
    );
  }
}

class Controle extends StatefulWidget {
  const Controle({super.key});

  @override
  State<Controle> createState() => _ControleState();
}

class _ControleState extends State<Controle> {
  final Random _aleatorio = Random();
  List<Pergunta> _questoes = [];
  List<int> _opcoes = [];
  int _qualPergunta = 0;
  int _acertos = 0;
  bool _quizIniciado = false;
  bool _quizFinalizado = false;
  bool _respondendo = false;
  OverlayEntry? _toastEntry;

  void _iniciarQuiz() {
    final questoes = gerarQuestoes();
    setState(() {
      _questoes = questoes;
      _qualPergunta = 0;
      _acertos = 0;
      _opcoes = _gerarOpcoes(questoes.first);
      _quizIniciado = true;
      _quizFinalizado = false;
      _respondendo = false;
    });
  }

  List<int> _gerarOpcoes(Pergunta pergunta) {
    final opcoes = <int>{pergunta.resposta};
    while (opcoes.length < 4) {
      opcoes.add(_aleatorio.nextInt(100) + 1);
    }
    return opcoes.toList()..shuffle(_aleatorio);
  }

  Future<void> _responder(int resposta) async {
    if (_respondendo) {
      return;
    }

    final pergunta = _questoes[_qualPergunta];
    final acertou = resposta == pergunta.resposta;

    setState(() {
      _respondendo = true;
      if (acertou) {
        _acertos++;
      }
    });

    late final OverlayEntry toast;
    toast = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.paddingOf(context).top + kToolbarHeight + 16,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: acertou ? Colors.green.shade700 : Colors.red.shade700,
            elevation: 6,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: acertou ? null : () => _continuarAposErro(toast),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  acertou ? 'Acertou!' : 'Errou, clique aqui para continuar.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    _toastEntry = toast;
    Overlay.of(context).insert(toast);

    if (!acertou) {
      return;
    }

    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    _removerToast(toast);
    setState(() {
      _qualPergunta++;
      if (_qualPergunta == _questoes.length) {
        _quizFinalizado = true;
      } else {
        _opcoes = _gerarOpcoes(_questoes[_qualPergunta]);
      }
      _respondendo = false;
    });
  }

  void _continuarAposErro(OverlayEntry toast) {
    if (!mounted || !identical(_toastEntry, toast)) {
      return;
    }

    _removerToast(toast);
    setState(() {
      _respondendo = false;
    });
  }

  void _removerToast(OverlayEntry toast) {
    if (identical(_toastEntry, toast)) {
      _toastEntry = null;
      toast.remove();
    }
  }

  @override
  void dispose() {
    final toast = _toastEntry;
    if (toast != null) {
      _removerToast(toast);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_quizIniciado) {
      return _telaInicial();
    }
    if (_quizFinalizado) {
      return _telaResultado();
    }
    return _telaPergunta();
  }

  Widget _telaInicial() {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz de multiplicação')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calculate,
                size: 96,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Vamos praticar multiplicação?',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Responda 10 perguntas com fatores de 1 a 10.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _iniciarQuiz,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _telaPergunta() {
    final pergunta = _questoes[_qualPergunta];
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Multiplicação')),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Questão ${_qualPergunta + 1} de ${_questoes.length}',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.titleMedium,
                  ),
                  SnackBarExample(),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_qualPergunta + 1) / _questoes.length,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    pergunta.enunciado,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  for (final opcao in _opcoes) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FilledButton(
                        key: ValueKey<int>(opcao),
                        onPressed:
                            _respondendo ? null : () => _responder(opcao),
                        child: Text(
                          '$opcao',
                          style: tema.textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _telaResultado() {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events,
                size: 96,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Você acertou $_acertos de ${_questoes.length} questões!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _iniciarQuiz,
                icon: const Icon(Icons.refresh),
                label: const Text('Jogar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SnackBarExample extends StatelessWidget {
  const SnackBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Show Snackbar'),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(''),
            action: SnackBarAction(
              label: 'Action',
              onPressed: () {
                // Code to execute.
              },
            ),
            width: 280.0,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}