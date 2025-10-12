import 'dart:convert';
import 'package:http/http.dart' as http;

class Service {
  final String url = 'http://localhost:8080/hello_widget';
  Future<Map<String, dynamic>> performAction() async {
    try {
      final result = await _callService();
      return result;
    } catch (e) {
      print('Erro ao chamar o serviço: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
    
  Future<Map<String, dynamic>> _callService() async {
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      data['success'] = true;
      return data;
    } else {
      throw Exception('Falha ao chamar o serviço: ${response.statusCode}');
    }
  }
}
