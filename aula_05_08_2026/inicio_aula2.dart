import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 62, 134, 223),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.red,
              Colors.lightBlue,
            ]),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,\ 
          ),
          child: const Center(
            child: Text('Hello World!'
            style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
            ),
          ),
        ),
      ),
    ),
  );
}
