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
  TextEditingController controlador = TextEditingController();

  void salvar() async {
    final prefs = await SharedPreferences.getInstance();
    final numeroSalvo = prefs.get('numero');
    print('Numero salvo: ' + numeroSalvo.toString());

    print('Salvando x:' + controlador.text);
    await prefs.setInt('numero', int.parse(controlador.text));
    print('Numero salvo: ' + numeroSalvo.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Text('Antes de salvar'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Digite um número!',
                    border: OutlineInputBorder(),
                  ),
                  controller: controlador,
                ),
              ),
              ElevatedButton(onPressed: salvar, child: Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
