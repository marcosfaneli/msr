# Sagittarius

Um servidor web simples em Dart com um endpoint `/hello`.

## Como executar

```bash
dart run bin/server.dart
```

O servidor será iniciado na porta 8080 (ou na porta definida pela variável de ambiente `PORT`).

## Endpoints

- `GET /hello` - Retorna "Hello, World!"

## Exemplo

```bash
curl http://localhost:8080/hello
```

Resposta: `Hello, World!`

Uses [`package:web`](https://pub.dev/packages/web)
to interop with JS and the DOM.

## Running and building

To run the app,
activate and use [`package:webdev`](https://dart.dev/tools/webdev):

```
dart pub global activate webdev
webdev serve
```

To build a production version ready for deployment,
use the `webdev build` command:

```
webdev build
```

To learn how to interop with web APIs and other JS libraries,
check out https://dart.dev/interop/js-interop.
