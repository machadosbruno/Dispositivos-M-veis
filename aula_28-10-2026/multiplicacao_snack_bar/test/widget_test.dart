import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:multiplicacao_snack_bar/main.dart';

Future<void> iniciar(WidgetTester tester) async {
  await tester.pumpWidget(const MultiplicacaoApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('Iniciar'));
  await tester.pump();
}

Future<void> responder(WidgetTester tester, int valor) async {
  for (final digito in '$valor'.split('')) {
    await tester.tap(find.byKey(Key('tecla_$digito')));
  }
  await tester.tap(find.byKey(const Key('confirmar')));
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('erro com clique na mensagem continua no fator atual',
      (WidgetTester tester) async {
    await iniciar(tester);
    expect(find.text('Tabuada do 1: questão 1 de 10'), findsOneWidget);

    await responder(tester, 9);
    await tester.pumpAndSettle();
    expect(find.text('Errou, clique aqui para continuar.'), findsOneWidget);

    await tester.tap(find.text('Errou, clique aqui para continuar.'));
    await tester.pumpAndSettle();
    expect(find.text('Tabuada do 1: questão 1 de 10'), findsOneWidget);

    await responder(tester, 1);
    expect(find.text('Acertou!'), findsOneWidget);
    expect(find.text('Tabuada do 1: questão 2 de 10'), findsOneWidget);
  });

  testWidgets('erro sem clique muda de fator', (WidgetTester tester) async {
    await iniciar(tester);

    await responder(tester, 9);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Tabuada do 2: questão 1 de 10'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('fator'), 2);
  });

  testWidgets('acertar todas muda de fator e salva a posição',
      (WidgetTester tester) async {
    await iniciar(tester);

    for (var multiplicador = 1; multiplicador <= 10; multiplicador++) {
      expect(
        find.text('Tabuada do 1: questão $multiplicador de 10'),
        findsOneWidget,
      );
      await responder(tester, multiplicador);
    }

    expect(find.text('Tabuada do 2: questão 1 de 10'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('fator'), 2);
    expect(prefs.getInt('multiplicador'), 1);
  });

  testWidgets('teclado permite apagar dígitos', (WidgetTester tester) async {
    await iniciar(tester);

    await tester.tap(find.byKey(const Key('tecla_4')));
    await tester.tap(find.byKey(const Key('tecla_2')));
    await tester.pump();
    expect(
      find.descendant(
          of: find.byKey(const Key('visor')), matching: find.text('42')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('apagar')));
    await tester.pump();
    expect(
      find.descendant(
          of: find.byKey(const Key('visor')), matching: find.text('4')),
      findsOneWidget,
    );
  });

  testWidgets('retoma a posição salva', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'fator': 3, 'multiplicador': 5});

    await tester.pumpWidget(const MultiplicacaoApp());
    await tester.pumpAndSettle();
    expect(
      find.text('Continue de onde parou: tabuada do 3, questão 5.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Iniciar'));
    await tester.pump();
    expect(find.text('Tabuada do 3: questão 5 de 10'), findsOneWidget);
    expect(find.text('3 x 5 = ?'), findsOneWidget);
  });
}
