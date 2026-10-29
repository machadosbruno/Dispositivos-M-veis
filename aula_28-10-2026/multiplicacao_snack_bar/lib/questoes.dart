const totalFatores = 10;
const multiplicadoresPorFator = 10;

class Pergunta {
  const Pergunta(this.fator1, this.fator2);

  final int fator1;
  final int fator2;

  int get resposta => fator1 * fator2;

  String get enunciado => '$fator1 x $fator2 = ?';
}
