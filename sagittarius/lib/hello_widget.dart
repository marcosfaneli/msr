import 'dart:convert';

class HelloWidget {
  String lib = 'package:mfaneli/main.dart';
  String className = 'HelloWorld.';
  String bytecode = '';
  String code = '''
    import 'package:flutter/material.dart';

    class HelloWorld extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello, World!',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              TextField(
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite algo',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print('Button Pressed!');
                },
                child: Text('Press Me'),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }
    }
    ''';

  String toJson() {
    return jsonEncode({
      'lib': lib,
      'className': className,
      'code': code, // Envia código para compilar no cliente
    });
  }
}
