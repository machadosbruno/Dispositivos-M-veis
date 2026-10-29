import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 50,
          minHeight: 50,
	  // usado:
          maxHeight: 100,
          maxWidth: 100,
        ),
        child: Placeholder(),
      ),
    );
  }
}
