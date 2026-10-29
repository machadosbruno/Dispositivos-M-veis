import 'package:flutter/material.dart';
import 'package:multiplicacao_snack_bar/questoes.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _chaveFator = 'fator';
  static const _chaveMultiplicador = 'multiplicador';

  int _fator = 1;
  int _multiplicador = 1;
  String _resposta = '';
  bool _carregado = false;
  bool _quizIniciado = false;
  bool _aguardandoClique = false;

  Pergunta get _pergunta => Pergunta(_fator, _multiplicador);

  @override
  void initState() {
    super.initState();
    _carregarPosicao();
  }

  Future<void> _carregarPosicao() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _fator = prefs.getInt(_chaveFator) ?? 1;
      _multiplicador = prefs.getInt(_chaveMultiplicador) ?? 1;
      _carregado = true;
    });
  }

  Future<void> _salvarPosicao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveFator, _fator);
    await prefs.setInt(_chaveMultiplicador, _multiplicador);
  }

  void _iniciarQuiz() {
    setState(() {
      _quizIniciado = true;
      _resposta = '';
    });
  }

  // Avança para o próximo fator, voltando ao 1 depois do último.
  void _mudarFator() {
    _fator = _fator % totalFatores + 1;
    _multiplicador = 1;
  }

  void _digitar(int digito) {
    if (_aguardandoClique || _resposta.length >= 3) {
      return;
    }
    setState(() {
      _resposta += '$digito';
    });
  }

  void _apagar() {
    if (_aguardandoClique || _resposta.isEmpty) {
      return;
    }
    setState(() {
      _resposta = _resposta.substring(0, _resposta.length - 1);
    });
  }

  void _confirmar() {
    if (_aguardandoClique || _resposta.isEmpty) {
      return;
    }
    if (int.parse(_resposta) == _pergunta.resposta) {
      _acertou();
    } else {
      _errou();
    }
  }

  void _acertou() {
    final completouFator = _multiplicador == multiplicadoresPorFator;
    setState(() {
      _resposta = '';
      if (completouFator) {
        _mudarFator();
      } else {
        _multiplicador++;
      }
    });
    _salvarPosicao();
    _mostrarMensagem(
      completouFator
          ? 'Acertou todas! Agora a tabuada do $_fator.'
          : 'Acertou!',
      Colors.green.shade700,
    );
  }

  Future<void> _errou() async {
    setState(() {
      _aguardandoClique = true;
      _resposta = '';
    });

    final mensageiro = ScaffoldMessenger.of(context)..clearSnackBars();
    final motivo = await mensageiro
        .showSnackBar(
          SnackBar(
            content: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => mensageiro.hideCurrentSnackBar(
                reason: SnackBarClosedReason.action,
              ),
              child: const Text(
                'Errou, clique aqui para continuar.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            width: 320,
          ),
        )
        .closed;

    if (!mounted) {
      return;
    }

    // Clicou na mensagem: continua no fator atual.
    // Não clicou: a sequência termina e muda de fator.
    final continuar = motivo == SnackBarClosedReason.action;
    setState(() {
      _aguardandoClique = false;
      if (!continuar) {
        _mudarFator();
      }
    });
    if (!continuar) {
      _salvarPosicao();
      _mostrarMensagem(
        'Mudando para a tabuada do $_fator.',
        Colors.orange.shade800,
      );
    }
  }

  void _mostrarMensagem(String texto, Color cor) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: cor,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          width: 320,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (!_carregado) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_quizIniciado) {
      return _telaInicial();
    }
    return _telaPergunta();
  }

  Widget _telaInicial() {
    final comecando = _fator == 1 && _multiplicador == 1;

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
              Text(
                comecando
                    ? 'Acerte toda a tabuada de cada fator, de 1 a 10.'
                    : 'Continue de onde parou: tabuada do $_fator, '
                        'questão $_multiplicador.',
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
                    'Tabuada do $_fator: questão $_multiplicador de '
                    '$multiplicadoresPorFator',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_multiplicador - 1) / multiplicadoresPorFator,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _pergunta.enunciado,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    key: const Key('visor'),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: tema.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _resposta.isEmpty ? ' ' : _resposta,
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _teclado(tema),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _teclado(ThemeData tema) {
    final habilitado = !_aguardandoClique;

    Widget tecla(Key key, Widget rotulo, VoidCallback onPressed,
        {bool destaque = false}) {
      final acao = habilitado ? onPressed : null;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: 56,
            child: destaque
                ? FilledButton(key: key, onPressed: acao, child: rotulo)
                : FilledButton.tonal(key: key, onPressed: acao, child: rotulo),
          ),
        ),
      );
    }

    Widget digito(int numero) => tecla(
          Key('tecla_$numero'),
          Text('$numero', style: tema.textTheme.titleLarge),
          () => _digitar(numero),
        );

    return Column(
      children: [
        for (final linha in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(children: [for (final numero in linha) digito(numero)]),
        Row(
          children: [
            tecla(
              const Key('apagar'),
              const Icon(Icons.backspace_outlined),
              _apagar,
            ),
            digito(0),
            tecla(
              const Key('confirmar'),
              const Icon(Icons.check),
              _confirmar,
              destaque: true,
            ),
          ],
        ),
      ],
    );
  }
}
