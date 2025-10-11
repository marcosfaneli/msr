# Flutter Eval - Hello World

Este é um projeto **extremamente simples** demonstrando o uso básico da biblioteca `flutter_eval`.

## O que é flutter_eval?

`flutter_eval` é uma biblioteca que permite:
- Escrever código Flutter como **string**
- Compilar e renderizar widgets dinamicamente em runtime
- Fazer code push (atualizar partes do app sem republicar)
- Criar UIs dinâmicas baseadas em servidor

## Como funciona este exemplo

O código está em `lib/main.dart` e usa o widget `EvalWidget` que:

1. Recebe uma **string** contendo código Dart/Flutter
2. Compila esse código em bytecode (modo debug) ou carrega bytecode pré-compilado (modo release)
3. Executa e renderiza o widget resultante

```dart
EvalWidget(
  packages: {
    'example': {
      'main.dart': '''
        import 'package:flutter/material.dart';
        
        class HelloWorld extends StatelessWidget {
          @override
          Widget build(BuildContext context) {
            return Container(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Hello World!',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            );
          }
        }
      ''',
    }
  },
  assetPath: 'assets/hello_world.evc',
  library: 'package:example/main.dart',
  function: 'HelloWorld.',
  args: const [],
)
```

## Como executar

```bash
# Entrar no diretório do projeto
cd nebula

# Executar em modo debug (compila a string em runtime)
flutter run
```

## Próximos passos

Este é apenas o **Hello World**. Com a base funcionando, você pode:

- Explorar widgets mais complexos
- Testar passagem de argumentos
- Experimentar compilação offline com `dart_eval compile`
- Implementar code push de verdade
- Criar UIs completamente dinâmicas

## Dependências

- `flutter_eval: ^0.8.1`

## Observações importantes

- Em **modo debug**: compila a string em runtime (~0.1s)
- Em **modo release**: carrega bytecode pré-compilado (.evc)
- Nem todos os widgets/features do Flutter são suportados
- Veja a lista de widgets suportados na [documentação oficial](https://pub.dev/packages/flutter_eval)
