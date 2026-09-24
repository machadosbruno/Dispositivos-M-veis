import 'package:flutter/material.dart';

void SecondScreen() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: GestureDetector(
            child: Text('Aperte!'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const SecondScreen(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
