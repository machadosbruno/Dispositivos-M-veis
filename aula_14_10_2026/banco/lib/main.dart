import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controlaNome = TextEditingController();
  TextEditingController controlaDono = TextEditingController();
  TextEditingController controlaIdade = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: controlaNome,
                  decoration: const InputDecoration(
                    labelText: 'Nome do pet',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: controlaDono,
                  decoration: const InputDecoration(
                    labelText: 'Dono do pet',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: controlaIdade,
                  decoration: const InputDecoration(
                    labelText: 'Idade do pet',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                  onPressed: () {
                    print(controlaNome.text);
                    print(controlaDono.text);
                    print(controlaIdade.text);
                  },
                  child: Text('Salvar'))
            ],
          ),
        ),
      ),
    );
  }
}
