import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as shelf;
import 'package:dart_eval/dart_eval.dart';
import 'package:flutter_eval/flutter_eval.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Eval Server',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const ServerPage(),
    );
  }
}

class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  HttpServer? server;
  String status = 'Iniciando...';
  String? error;

  @override
  void initState() {
    super.initState();
    startServer();
  }

  Future<void> startServer() async {
    try {
      final app = shelf.Router();

      // Endpoint de compilação
      app.post('/compile', (Request request) async {
        try {
          final payload = jsonDecode(await request.readAsString());

          final code = payload['code'] as String?;
          final lib = payload['lib'] as String? ?? 'hello';
          final className = payload['className'] as String? ?? 'HelloWidget';

          if (code == null || code.isEmpty) {
            return Response.badRequest(
              body: jsonEncode({'error': 'Campo "code" é obrigatório'}),
              headers: {'Content-Type': 'application/json'},
            );
          }

          print('[COMPILE] Iniciando compilação para $lib:$className');
          print('[COMPILE] Código recebido (${code.length} caracteres)');

          // Compilar o código usando flutter_eval
          final compiler = Compiler();

          // Adicionar o plugin do Flutter para acesso às APIs do Flutter
          compiler.addPlugin(flutterEvalPlugin);

          // Compilar o código
          final program = compiler.compile({
            lib: {className: code},
          });

          // Converter o bytecode para base64
          final bytecode = program.write();
          final base64Bytecode = base64Encode(bytecode.buffer.asUint8List());

          print(
            '[COMPILE] Compilação concluída! Bytecode: ${bytecode.lengthInBytes} bytes',
          );
          print('[COMPILE] Base64 length: ${base64Bytecode.length} caracteres');

          return Response.ok(
            jsonEncode({
              'lib': lib,
              'className': className,
              'bytecode': base64Bytecode,
              'size': bytecode.lengthInBytes,
            }),
            headers: {'Content-Type': 'application/json'},
          );
        } catch (e, stackTrace) {
          print('[COMPILE ERROR] $e');
          print('[COMPILE ERROR STACK] $stackTrace');

          return Response.internalServerError(
            body: jsonEncode({
              'error': 'Erro ao compilar: $e',
              'details': stackTrace.toString(),
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      });

      // Endpoint de execução - Compila o hello_widget padrão
      app.post('/execute', (Request request) async {
        try {
          print('[EXECUTE] Iniciando compilação do hello_widget padrão');

          // Ler o arquivo hello_widget.dart
          final helloWidgetFile = File('bin/hello_widget.dart');
          if (!await helloWidgetFile.exists()) {
            return Response.notFound(
              jsonEncode({'error': 'Arquivo hello_widget.dart não encontrado'}),
              headers: {'Content-Type': 'application/json'},
            );
          }

          final code = await helloWidgetFile.readAsString();
          final lib = 'mfaneli';
          final className = 'HelloWorld';

          print('[EXECUTE] Código carregado (${code.length} caracteres)');

          // Compilar o código usando flutter_eval
          final compiler = Compiler();

          // Adicionar o plugin do Flutter para acesso às APIs do Flutter
          compiler.addPlugin(flutterEvalPlugin);

          // Compilar o código
          final program = compiler.compile({
            lib: {'main.dart': code},
          });

          // Converter o bytecode para base64
          final bytecode = program.write();
          final base64Bytecode = base64Encode(bytecode.buffer.asUint8List());

          print(
            '[EXECUTE] Compilação concluída! Bytecode: ${bytecode.lengthInBytes} bytes',
          );
          print('[EXECUTE] Base64 length: ${base64Bytecode.length} caracteres');

          return Response.ok(
            jsonEncode({
              'lib': lib,
              'className': className,
              'bytecode': base64Bytecode,
              'size': bytecode.lengthInBytes,
            }),
            headers: {'Content-Type': 'application/json'},
          );
        } catch (e, stackTrace) {
          print('[EXECUTE ERROR] $e');
          print('[EXECUTE ERROR STACK] $stackTrace');

          return Response.internalServerError(
            body: jsonEncode({
              'error': 'Erro ao compilar: $e',
              'details': stackTrace.toString(),
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      });

      // Health check
      app.get('/health', (Request request) {
        return Response.ok(
          jsonEncode({'status': 'ok', 'service': 'flutter-eval-compiler'}),
          headers: {'Content-Type': 'application/json'},
        );
      });

      // Iniciar o servidor
      final port = int.tryParse(Platform.environment['PORT'] ?? '8081') ?? 8081;
      server = await io.serve(app, InternetAddress.anyIPv4, port);

      setState(() {
        status = 'Rodando em http://${server!.address.host}:${server!.port}';
      });

      print('═══════════════════════════════════════════════════════');
      print('🚀 Flutter Eval Compilation Server');
      print('═══════════════════════════════════════════════════════');
      print('📡 Listening on: http://${server!.address.host}:${server!.port}');
      print('📋 Endpoints:');
      print('   POST /compile  - Compila código Flutter para bytecode');
      print('   POST /execute  - Compila hello_widget.dart padrão');
      print('   GET  /health   - Health check');
      print('═══════════════════════════════════════════════════════');
    } catch (e) {
      setState(() {
        error = e.toString();
        status = 'Erro ao iniciar';
      });
      print('Erro ao iniciar servidor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Eval Compilation Server'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Flutter Eval Compilation Server',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              status,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(
                'Erro: $error',
                style: const TextStyle(fontSize: 14, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    server?.close();
    super.dispose();
  }
}
