import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Center: não tem parent, ocupa tudo.
    // SizedBox: ocupa 200.
    // Placeholder: ocupa 200.
    return Center(child: SizedBox(width: 200, child: const Placeholder()));
  }
}
