import 'package:sagittarius/hello_widget.dart';

class HelloWidgetService {
  HelloWidget process() {
    final widget = HelloWidget();

    // Backend NÃO compila código Flutter
    // Apenas retorna o código que será compilado no cliente
    // O cliente Flutter tem o flutterEvalPlugin necessário

    print('Preparando widget para envio ao cliente');
    print('Código tem ${widget.code.length} caracteres');

    // bytecode fica vazio - será compilado no cliente
    widget.bytecode = '';

    return widget;
  }
}
