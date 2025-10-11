import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Runtime? _runtime;
  bool _isCompiling = false;
  String? _error;
  final TextEditingController _inputCode = TextEditingController();

  String _code = '''
    import 'package:flutter/material.dart';
    
    class HelloWorld extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('texto 1'),
            Text('texto 2'),
            Text('texto 3'),
          ],
        );
      }
    }
  ''';

  @override
  void dispose() {
    _inputCode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _inputCode.text = _code;
  }

  void updateCode(String code) {
    setState(() {
      _error = null;
      _code = code;
    });
  }

  void _compileCode(String code) async {
    try {
      setState(() {
        _isCompiling = true;
        _error = null;
      });

      // added sleep
      await Future.delayed(const Duration(seconds: 1));

      // 1. Criar o compilador
      final compiler = Compiler();

      // 2. Adicionar o plugin do Flutter (IMPORTANTE!)
      compiler.addPlugin(flutterEvalPlugin);

      // 3. Compilar o código Dart
      final program = compiler.compile({
        'mfaneli': {'main.dart': code},
      });

      // 4. Criar o Runtime a partir do programa compilado
      final runtime = Runtime.ofProgram(program);

      // 5. Adicionar o plugin do Flutter no runtime também
      runtime.addPlugin(flutterEvalPlugin);

      setState(() {
        _runtime = runtime;
        _isCompiling = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isCompiling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Dinâmico'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: _inputCode,
              maxLines: 10,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Digite o código Dart aqui',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => updateCode(value),
            ),
            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 20),
            _buildBody(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _compileCode(_code),
        tooltip: 'Compilar Código',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody() {
    // Mostrar loading enquanto compila
    if (_isCompiling) {
      return compiling();
    }

    // Mostrar erro se houver
    if (_error != null) {
      return showError();
    }

    // Executar o código compilado
    if (_runtime != null) {
      return render();
    }

    return const Text('Runtime não inicializado');
  }

  Column compiling() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text('Compilando código...'),
      ],
    );
  }

  Widget render() {
    try {
      // Executar a função HelloWorld do código compilado
      final result = _runtime!.executeLib(
        'package:mfaneli/main.dart', // Biblioteca
        'HelloWorld.', // Função (construtor)
        [], // Argumentos
      );
    
      // Extrair o Widget do resultado
      return (result as $Value).$value as Widget;
    } catch (e) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.orange, size: 64),
          const SizedBox(height: 20),
          const Text(
            'Erro ao executar:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(e.toString(), textAlign: TextAlign.center),
          ),
        ],
      );
    }
  }

  Column showError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 64),
        const SizedBox(height: 20),
        const Text(
          'Erro ao compilar:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
