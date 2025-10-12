import 'dart:convert';

class HelloWidget {
  String lib = 'package:mfaneli/main.dart';
  String className = 'HelloWorld.';
  String bytecode = '''
    import 'package:flutter/material.dart';

    class HelloWorld extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
            TextField(
              decoration: InputDecoration(
                multiline: true,
                minLines: 3,
                keyboardType: TextInputType.multiline,
                border: OutlineInputBorder(),
                labelText: 'Digite algo',
              ),
            )
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
      'bytecode': bytecode,
    });
  }
}
