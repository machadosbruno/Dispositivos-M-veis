class Pergunta {
  const Pergunta(this.textoPergunta, this.respostas);
  final String textoPergunta;
  final List<String> respostas;

  List<String> Embaralha() {
    var respostasEmbaralhadas = List.of(respostas);
    respostasEmbaralhadas.shuffle();
    return (respostasEmbaralhadas);
  }
}
