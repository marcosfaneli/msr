import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerService {
  final String url = 'http://localhost:8081/execute';

  Future<Map<String, dynamic>> executeRemoteWidget() async {
    try {
      final result = await _callService();
      return result;
    } catch (e) {
      print('Erro ao chamar o serviço server: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _callService() async {
    final response = await http.post(Uri.parse(url));

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
}
