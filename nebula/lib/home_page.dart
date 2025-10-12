import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:nebula/service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Runtime? _runtime;
  bool _isCompiling = false;
  String? _error;

  Service service = Service();

  final TextEditingController _inputCode = TextEditingController();

  String _className = 'HelloWorld.';
  String _lib = 'package:mfaneli/main.dart';
  String _code = '''
    import 'package:flutter/material.dart';
    
    class HelloWorld extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return Text('texto 1');
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

  void _compileCode() async {
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
        'mfaneli': {'main.dart': _code},
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadRemoteCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text('Executar Widget Remoto'),
            ),
            const SizedBox(height: 10),
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
    );
  }

  Widget _buildBody() {
    // Mostrar loading enquanto compila
    if (_isCompiling) {
      return showLoader();
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

  Column showLoader() {
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
        _lib, // Biblioteca
        _className, // Função (construtor)
        [], // Argumentos
      );

      // Extrair o Widget do resultado
      return (result as $Value).$value as Widget;
    } catch (e) {
      return showErroRender(e);
    }
  }

  Column showErroRender(Object e) {
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

  void _loadRemoteCode() async {
    final response = await service.performAction();

    if (response['success']) {
      print(response);
      setState(() {
        _className = response['className'];
        _lib = response['lib'];
        _code = response['code'];
        _inputCode.text = _code;
      });
      _compileCode();
    } else {
      final error = response['error'];
      setState(() {
        _error = error;
      });
      showError();
    }
  }
}
