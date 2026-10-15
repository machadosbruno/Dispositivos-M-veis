import 'package:caes_com_janelas/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('exibe as quatro abas do CRUD de pets', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Salvar'), findsOneWidget);
    expect(find.text('Listar'), findsOneWidget);
    expect(find.text('Atualizar'), findsOneWidget);
    expect(find.text('Apagar'), findsOneWidget);
    expect(find.text('Nome do pet'), findsOneWidget);
    expect(find.text('Idade do pet'), findsOneWidget);
    final tabBarView = tester.widget<TabBarView>(find.byType(TabBarView));
    expect(tabBarView.children, hasLength(4));
  });

  testWidgets('valida os campos obrigatórios antes de salvar', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar pet'));
    await tester.pumpAndSettle();

    expect(find.text('Preencha este campo.'), findsOneWidget);
    expect(find.text('Informe um número inteiro válido.'), findsOneWidget);
  });
}
