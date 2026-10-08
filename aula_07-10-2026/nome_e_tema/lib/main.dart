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
  String x = '';
  bool azul = false;
  String texto = 'Rosa';

  @override
  void initState() {
    super.initState();
    buscaX();
    buscaAzul();
  }

  void buscaX() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      x = prefs.getString('nome') ?? '';
    });
    print('Mostrando x: $x');
  }

  void buscaAzul() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      azul = prefs.getBool('azul') ?? false;
      texto = azul ? 'Azul' : 'Rosa';
    });
  }

  void salvar() async {
    final prefs = await SharedPreferences.getInstance();
    String x = controlador.text;
    await prefs.setString('nome', x);

    print('Salvando x:' + controlador.text);
    buscaX();
  }

  void salvarAzul() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('azul', azul);
  }

  void apagar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nome');
    buscaX();
  }

  void mudaAzul(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      azul = valor;
      texto = azul ? 'Azul' : 'Rosa';
    });
    salvarAzul();
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
              Text('Olá $x'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Digite seu nome!',
                    border: OutlineInputBorder(),
                  ),
                  controller: controlador,
                ),
              ),
              Row(
                children: [
                  ElevatedButton(onPressed: salvar, child: Text('Salvar')),
                  ElevatedButton(onPressed: apagar, child: Text('Apagar')),
                ],
              ),
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
