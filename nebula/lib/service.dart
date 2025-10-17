import 'dart:convert';
import 'package:http/http.dart' as http;

class Service {
  final String executeUrl = 'http://localhost:8081/execute';
  final String compileUrl = 'http://localhost:8081/compile';

  Future<Map<String, dynamic>> executeRemoteWidget() async {
    try {
      final result = await _callExecuteService();
      return result;
    } catch (e) {
      print('Erro ao chamar o serviço server: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> compileCode(
    String code,
    String className,
  ) async {
    try {
      final result = await _callCompileService(code, className);
      return result;
    } catch (e) {
      print('Erro ao compilar código no servidor: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _callExecuteService() async {
    final response = await http.post(Uri.parse(executeUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // O server retorna bytecode compilado, não código fonte
      // Precisamos retornar em formato compatível
      data['success'] = true;
      return data;
    } else {
      throw Exception('Falha ao chamar o serviço: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _callCompileService(
    String code,
    String className,
  ) async {
    final response = await http.post(
      Uri.parse(compileUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'lib': 'mfaneli',
        'className': className.isNotEmpty ? className : 'HelloWorld',
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      data['success'] = true;
      return data;
    } else {
      throw Exception('Falha ao compilar código: ${response.statusCode}');
    }
  }
}
