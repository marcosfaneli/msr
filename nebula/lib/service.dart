import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Service {
  final String url = 'http://localhost:8080/hello_widget';
  Future<Map<String, dynamic>> performAction() async {
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Ação do serviço executada com sucesso!');
      final data = json.decode(response.body);

      return {
        'success': true,
        'className': data['className'],
        'lib': data['lib'],
        'bytecode': data['bytecode'],
      };
    } else {
      print('Falha ao executar a ação do serviço. Código: ${response.statusCode}');
      return {'success': false, 'error': response.statusCode};
    }
  }
}