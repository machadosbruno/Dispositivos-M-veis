import 'dart:math';

String reservaMesa() {
  var mesa = buscaMesa();
  return 'Sua mesa é: $mesa';
}

String buscaMesa() {
  Future.delay
  var random = Random().nextInt(10) + 1;
  
  return random.toString();
}

void main() {
  print(reservaMesa());
}