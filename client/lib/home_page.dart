import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:nebula/service.dart';
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

  Service serverService = Service();

  final TextEditingController _inputCode = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();

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
    _classNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _inputCode.text = _code;
    _classNameController.text = 'HelloWorld'; // Nome padrão da classe
  }

  void updateCode(String code) {
    setState(() {
      _error = null;
      _code = code;
    });
  }

  void _compileCodeOnServer() async {
    setState(() {
      _isCompiling = true;
      _error = null;
    });

    try {
      print('[COMPILE SERVER] Enviando código para compilação no servidor');
      print('[COMPILE SERVER] Código: ${_code.length} caracteres');
      print('[COMPILE SERVER] Classe: ${_classNameController.text}');

      // Enviar código para o servidor compilar
      final response = await serverService.compileCode(
        _code,
        _classNameController.text.trim(),
      );

      if (response['success']) {
        print('[COMPILE SERVER] Resposta recebida: bytecode compilado');

        // O server retorna bytecode compilado em base64
        final String base64Bytecode = response['bytecode'];
        final String lib = response['lib'];
        final String className = response['className'];

        print(
          '[COMPILE SERVER] Decodificando bytecode (${base64Bytecode.length} chars)',
        );

        // Decodificar o bytecode de base64
        final bytecode = base64Decode(base64Bytecode);

        print(
          '[COMPILE SERVER] Bytecode decodificado: ${bytecode.length} bytes',
        );

        // Converter Uint8List para ByteData
        final byteData = ByteData.sublistView(bytecode);

        // Criar Runtime diretamente do bytecode
        final runtime = Runtime(byteData);

        // Adicionar o plugin do Flutter no runtime
        runtime.addPlugin(flutterEvalPlugin);

        setState(() {
          _runtime = runtime;
          _className = '$className.'; // Ex: HelloWorld.
          _lib = 'package:$lib/main.dart'; // Ex: package:mfaneli/main.dart
          _isCompiling = false;
        });

        print('[COMPILE SERVER] Runtime criado com sucesso!');
        print('[COMPILE SERVER] Vai executar: $_lib -> $_className');
      } else {
        final error = response['error'];
        setState(() {
          _error = 'Erro do servidor: $error';
          _isCompiling = false;
        });
      }
    } catch (e, stackTrace) {
      print('[COMPILE SERVER ERROR] $e');
      print('[COMPILE SERVER ERROR STACK] $stackTrace');
      setState(() {
        _error = 'Erro ao compilar no servidor: $e';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Botão 1: Buscar widget pré-compilado do servidor
            ElevatedButton(
              onPressed: _loadFromServer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text(
                'Buscar Widget Pré-compilado do Server (HelloWorld)',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            // Botão 2: Enviar código para compilar no servidor
            ElevatedButton(
              onPressed: _compileCodeOnServer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text(
                'Compilar Código Digitado no Server e Renderizar',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            // Campo para nome da classe
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(
                hintText: 'Ex: HelloWorld, MyWidget, Counter',
                border: OutlineInputBorder(),
                labelText: 'Nome da Classe',
                prefixIcon: Icon(Icons.class_),
              ),
            ),
            const SizedBox(height: 20),
            // Campo de texto para código
            Expanded(
              flex: 2,
              child: TextField(
                controller: _inputCode,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Digite o código Dart aqui',
                  border: OutlineInputBorder(),
                  labelText: 'Código Flutter/Dart',
                ),
                onChanged: (value) => updateCode(value),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            // Área de renderização
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: _buildBody()),
              ),
            ),
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
