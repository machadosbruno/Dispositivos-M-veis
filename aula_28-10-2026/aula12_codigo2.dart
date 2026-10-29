import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    // SizedBox não tem parent: 
    return SizedBox(width: 200, child: const Placeholder());
  }
}
