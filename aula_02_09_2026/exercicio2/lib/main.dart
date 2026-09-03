import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final letras = ['A', 'B', 'C'];

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            ...letras.map((letra) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    //margin: EdgeInsets.all(20)
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text(letra),
                    ),
                  ),
                ],
              );
            })
          ],
        ),
      ),
    );
  }
}
