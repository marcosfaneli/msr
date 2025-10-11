import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String code = '''
    import 'package:flutter/material.dart';
    
    class HelloWorld extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('texto 1'),
            Text('texto 2'),
          ],
        );
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nebula',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Nebula'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: CompilerWidget(
            packages: {
              'example': {
                'main.dart': code,
              },
            },
            library: 'package:example/main.dart',
            function: 'HelloWorld.',
            args: const [],
            // SEM assetPath! Nunca salva em arquivo
          ),
        ),
      ),
    );
  }
}
