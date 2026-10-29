import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // align é obrigado a ocupar toda a tela.
    // o padrão de align é: alignment: AlignmentGeometry.center,
    return Align(child: SizedBox(width: 200, child: const Placeholder()));
  }
}
