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
  TextEditingController controladorEstado = TextEditingController();
  TextEditingController controladorCidade = TextEditingController();
  TextEditingController controladorBairro = TextEditingController();
  TextEditingController controladorNumero = TextEditingController();
  int x = 0;

  @override
  void initState() {
    super.initState();
    buscaX();
  }

  void buscaX() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      x = prefs.getInt('x') ?? 0;
    });
    print('Mostrando x: $x');
  }

  void salvar() async {
    final prefs = await SharedPreferences.getInstance();
    int x = int.parse(controlador.text);
    await prefs.setInt('x', x);

    print('Salvando x:' + controlador.text);
    buscaX();
  }

  void apagar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('x');
    buscaX();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Text('Seu CEP: $x'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Digite seu cep (somente números)!',
                    border: OutlineInputBorder(),
                  ),
                  controller: controlador,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  controller: controladorEstado,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cidade',
                    border: OutlineInputBorder(),
                  ),
                  controller: controladorCidade,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Bairro',
                    border: OutlineInputBorder(),
                  ),
                  controller: controladorBairro,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Número',
                    border: OutlineInputBorder(),
                  ),
                  controller: controladorNumero,
                ),
              ),
              Row(
                children: [
                  ElevatedButton(onPressed: salvar, child: Text('Salvar')),
                  ElevatedButton(onPressed: apagar, child: Text('Apagar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
