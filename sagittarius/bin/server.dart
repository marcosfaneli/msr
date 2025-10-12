import 'dart:io';
import 'package:sagittarius/hello_widget_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_hotreload/shelf_hotreload.dart';
import '../lib/compiler_service.dart';
import '../lib/hello_widget.dart';

void main(List<String> args) {
  withHotreload(() => createServer());
}

Future<HttpServer> createServer() async {
  final app = Router();
  final compilerService = CompilerService();
  final helloWidgetService = HelloWidgetService();

  // Endpoint GET /hello
  app.get('/hello', (Request request) {
    return Response.ok(
      'Hello, World 7!',
      headers: {'Content-Type': 'text/plain'},
    );
  });

  app.post('/compile', (Request request) async {
    final body = await request.readAsString();
    final result = await compilerService.processCompileRequest(body);
    return Response.ok(
      result,
      headers: {'Content-Type': 'application/json'},
    );
  });

  app.put('/hello_widget', (Request request) {
    return Response.ok(
      helloWidgetService.process().toJson(),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Middleware para logging
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);

  // Configuração do servidor
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

  print('Servidor rodando em http://${server.address.host}:${server.port}');
  print('Acesse: http://localhost:$port/hello');
  print('Hot reload habilitado! 🔥');

  return server;
}
