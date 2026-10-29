import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: const Card(child: Text('Hello World!')),
        ),
      ),
    );
  }
}
