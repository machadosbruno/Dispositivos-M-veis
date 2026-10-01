import 'dart:math';

Future<String> reservaMesa() async {
  var mesa = await buscaMesa();
  return 'Sua mesa é: $mesa';
}

Future<String> buscaMesa() {
  return Future.delayed(const Duration(seconds: 2), () {
    var random = Random().nextInt(10) + 1;
  
    return random.toString();
  });
}

void main() async {
  print(await reservaMesa());
}