import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      // limitador ignorado por screen  
      constraints: BoxConstraints(
        minWidth: 50,
        minHeight: 50,
        maxHeight: 100,
        maxWidth: 100,
      ),
      child: Placeholder(),
    );
  }
}

