import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atividades_dia/atividade.dart';
import 'package:atividades_dia/config.dart';
import 'package:atividades_dia/main.dart';

void main() {
  group('datas', () {
    test('dataParaApi usa aaaa-mm-dd com zeros à esquerda', () {
      expect(dataParaApi(DateTime(2026, 3, 5)), '2026-03-05');
      expect(dataParaApi(DateTime(2026, 11, 25)), '2026-11-25');
    });

    test('dataParaTela usa dd/mm/aaaa', () {
      expect(dataParaTela(DateTime(2026, 3, 5)), '05/03/2026');
    });

    test('hoje() não tem horas', () {
      final dia = hoje();
      expect(dia.hour + dia.minute + dia.second + dia.millisecond, 0);
    });
  });

  group('Atividade', () {
    test('fromJson aceita id em texto e descrição nula', () {
      final atividade = Atividade.fromJson({
        'id': '3',
        'dia': '2026-11-02',
        'titulo': 'Estudar Flutter',
        'descricao': null,
      });
      expect(atividade.id, 3);
      expect(atividade.dia, DateTime(2026, 11, 2));
      expect(atividade.titulo, 'Estudar Flutter');
      expect(atividade.descricao, isNull);
    });

    test('agrupaPorDia junta as atividades do mesmo dia e mantém a ordem', () {
      Atividade nova(int id, int dia) => Atividade(
            id: id,
            dia: DateTime(2026, 11, dia),
            titulo: 'Atividade $id',
            descricao: null,
          );
      final grupos = agrupaPorDia([nova(1, 2), nova(2, 2), nova(3, 10)]);

      expect(grupos.keys.toList(), [DateTime(2026, 11, 2), DateTime(2026, 11, 10)]);
      expect(grupos[DateTime(2026, 11, 2)]!.map((a) => a.id), [1, 2]);
      expect(grupos[DateTime(2026, 11, 10)]!.map((a) => a.id), [3]);
    });
  });

  testWidgets('abre nas abas e não salva sem título', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.text('Atividades do mês'), findsOneWidget);
    expect(find.text('Dia: ${dataParaTela(hoje())}'), findsOneWidget);

    await tester.tap(find.byKey(const Key('formulario-salvar-botao')));
    await tester.pump();

    expect(find.text('Informe o título da atividade'), findsOneWidget);
  });
}
