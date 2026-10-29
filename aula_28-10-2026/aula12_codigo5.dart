import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Aqui placeholder pode usar a altura desejada
    return Align(
        alignment: AlignmentGeometry.bottomRight,
        child: SizedBox(width: 200, child: const Placeholder()));
  }
}
