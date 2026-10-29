import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // 120 repassado para child
        width: 120,
        height: 120,
        color: Colors.red,
        child: Container(
          color: Colors.green,
          // 100 ignorado, 120 usado no lugar
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}
