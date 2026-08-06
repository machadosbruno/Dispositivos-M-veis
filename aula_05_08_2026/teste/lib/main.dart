import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 82, 167, 236),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue,
                  Colors.black,
                ]),
          ),
          child: Center(
            child: Text(
              'Hello World!',
              style: TextStyle(fontSize: 30),
            ),
          ),
        ),
      ),
    ),
  );
}
