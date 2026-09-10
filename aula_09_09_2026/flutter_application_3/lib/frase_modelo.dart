class FraseModelo {
  final String texto;
  final String autor;
  bool like = false;

  FraseModelo({required this.texto, required this.autor});

  bool get liked => like;

  void mudaLike() {
    like = !like;
  }
}
