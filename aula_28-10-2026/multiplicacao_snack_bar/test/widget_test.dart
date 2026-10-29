import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:multiplicacao_snack_bar/main.dart';

void main() {
  testWidgets('erro aguarda clique e repete a mesma operação',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MultiplicacaoApp());
    await tester.tap(find.text('Iniciar'));
    await tester.pump();

    final textoPergunta = tester.widget<Text>(find.textContaining('= ?'));
    final fatores =
        RegExp(r'^(\d+) x (\d+) = \?$').firstMatch(textoPergunta.data!)!;
    final respostaCorreta =
        int.parse(fatores.group(1)!) * int.parse(fatores.group(2)!);
    final respostaErrada = tester
        .widgetList<FilledButton>(find.byType(FilledButton))
        .map((botao) => botao.key)
        .whereType<ValueKey<int>>()
        .map((chave) => chave.value)
        .firstWhere((opcao) => opcao != respostaCorreta);

    await tester.tap(find.byKey(ValueKey<int>(respostaErrada)));
    await tester.pump();

    expect(
      find.text('Errou, clique aqui para continuar.'),
      findsOneWidget,
    );
    expect(find.text('Questão 1 de 10'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Questão 1 de 10'), findsOneWidget);

    await tester.tap(find.text('Errou, clique aqui para continuar.'));
    await tester.pump();

    expect(find.text('Questão 1 de 10'), findsOneWidget);
    expect(find.byKey(ValueKey<int>(respostaErrada)), findsOneWidget);

    await tester.tap(find.byKey(ValueKey<int>(respostaCorreta)));
    await tester.pump();
    expect(find.text('Acertou!'), findsOneWidget);
    expect(find.text('Questão 1 de 10'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Questão 2 de 10'), findsOneWidget);
  });

  testWidgets('quiz apresenta fatores de 1 a 10 e conclui dez perguntas',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MultiplicacaoApp());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(
      app.theme!.colorScheme.primary,
      ColorScheme.fromSeed(seedColor: Colors.deepPurple).primary,
    );
    expect(find.text('Vamos praticar multiplicação?'), findsOneWidget);
    await tester.tap(find.text('Iniciar'));
    await tester.pump();

    final paresDeFatores = <String>{};
    for (var numeroQuestao = 1; numeroQuestao <= 10; numeroQuestao++) {
      expect(find.text('Questão $numeroQuestao de 10'), findsOneWidget);
      final textoPergunta = tester.widget<Text>(find.textContaining('= ?'));
      final fatores =
          RegExp(r'^(\d+) x (\d+) = \?$').firstMatch(textoPergunta.data!);
      expect(fatores, isNotNull);
      final fator1 = int.parse(fatores!.group(1)!);
      final fator2 = int.parse(fatores.group(2)!);
      expect(fator1, inInclusiveRange(1, 10));
      expect(fator2, inInclusiveRange(1, 10));
      expect(paresDeFatores.add('$fator1 x $fator2'), isTrue);

      await tester.tap(find.byKey(ValueKey<int>(fator1 * fator2)));
      await tester.pump();
      expect(find.text('Acertou!'), findsOneWidget);
      expect(find.text('Questão $numeroQuestao de 10'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
    }

    expect(paresDeFatores, hasLength(10));
    expect(find.text('Você acertou 10 de 10 questões!'), findsOneWidget);
    expect(find.text('Jogar novamente'), findsOneWidget);
  });
}
