import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        // Aqui placeholder pode usar a altura desejada
        alignment: AlignmentGeometry.bottomRight,
        child: SizedBox(width: 200, height: 200, child: const Placeholder()));
  }
}
