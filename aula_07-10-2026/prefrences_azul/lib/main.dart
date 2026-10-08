import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String texto = 'Rosa';
  bool azul = false;

  @override
  void initState() {
    super.initState();
    buscaX();
  }

  void buscaX() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      azul = prefs.getBool('azul') ?? false;
      texto = azul ? 'Azul' : 'Rosa';
    });
  }

  void salvar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('azul', azul);
  }

  void mudaAzul(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      azul = valor;
      texto = azul ? 'Azul' : 'Rosa';
    });
    salvar();
    print(prefs.getBool('azul'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Text('Cor: $texto'),
              Switch(
                value: azul,
                onChanged: mudaAzul,
                activeColor: Colors.lightBlue,
                inactiveThumbColor: Colors.pink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
