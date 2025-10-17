import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:nebula/service.dart';
import 'package:nebula/server_service.dart';
import 'dart:convert';
import 'dart:typed_data';

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
  ServerService serverService = ServerService();

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
              child: const Text('Executar Widget Remoto (Sagittarius)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadFromServer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Executar Widget do Server (HelloWorld)'),
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
    print(e.toString());
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

  void _loadFromServer() async {
    setState(() {
      _isCompiling = true;
      _error = null;
    });

    try {
      final response = await serverService.executeRemoteWidget();

      if (response['success']) {
        print('[SERVER] Resposta recebida: $response');

        // O server retorna bytecode compilado em base64
        final String base64Bytecode = response['bytecode'];
        final String lib = response['lib'];
        final String className = response['className'];

        print(
          '[SERVER] Decodificando bytecode (${base64Bytecode.length} chars)',
        );

        // Decodificar o bytecode de base64
        final bytecode = base64Decode(base64Bytecode);

        print('[SERVER] Bytecode decodificado: ${bytecode.length} bytes');

        // Converter Uint8List para ByteData
        final byteData = ByteData.sublistView(bytecode);

        // Criar Runtime diretamente do bytecode
        final runtime = Runtime(byteData);

        // Adicionar o plugin do Flutter no runtime
        runtime.addPlugin(flutterEvalPlugin);

        setState(() {
          _runtime = runtime;
          _className = '$className.'; // HelloWorld.
          _lib = 'package:$lib/main.dart'; // package:mfaneli/main.dart
          _isCompiling = false;
        });

        print('[SERVER] Runtime criado com sucesso!');
        print('[SERVER] Vai executar: $_lib -> $_className');
      } else {
        final error = response['error'];
        setState(() {
          _error = 'Erro do servidor: $error';
          _isCompiling = false;
        });
      }
    } catch (e, stackTrace) {
      print('[SERVER ERROR] $e');
      print('[SERVER ERROR STACK] $stackTrace');
      setState(() {
        _error = 'Erro ao carregar do server: $e';
        _isCompiling = false;
      });
    }
  }
}
