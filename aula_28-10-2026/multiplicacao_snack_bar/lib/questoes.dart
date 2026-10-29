class Pergunta {
  const Pergunta(this.fator1, this.fator2);

  final int fator1;
  final int fator2;

  int get resposta => fator1 * fator2;

  String get enunciado => '$fator1 x $fator2 = ?';
}

List<Pergunta> gerarQuestoes() {
  final questoes = [
    for (var fator1 = 1; fator1 <= 10; fator1++)
      for (var fator2 = 1; fator2 <= 10; fator2++) Pergunta(fator1, fator2),
  ]..shuffle();

  return questoes.take(10).toList();
}
