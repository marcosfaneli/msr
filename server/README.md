# Flutter Eval Compilation Server

Servidor HTTP baseado em Flutter que compila código Flutter dinamicamente para bytecode usando **flutter_eval**.

## 🎯 Propósito

Este servidor resolve a limitação de que `dart_eval` não pode compilar código Flutter em servidores Dart standalone (devido à indisponibilidade de `dart:ui`). Ao rodar como uma aplicação Flutter, temos acesso completo às APIs do Flutter e podemos compilar código que use widgets.

## 🏗️ Arquitetura

```
┌─────────────┐      código         ┌──────────────┐
│  Sagittarius│ ───────────────────>│ Server       │
│  (Backend)  │                     │ (Compilador) │
└─────────────┘                     └──────────────┘
                                            │
                                            │ bytecode
                                            ▼
                                     ┌──────────────┐
                                     │   Nebula     │
                                     │   (Client)   │
                                     └──────────────┘
```

1. **Sagittarius**: Backend principal, retorna código Flutter como string
2. **Server** (este projeto): Compila o código para bytecode `.evc`
3. **Nebula**: Cliente Flutter, executa o bytecode usando `RuntimeWidget`

## 🚀 Como Executar

```bash
# Instalar dependências
flutter pub get

# Rodar o servidor
dart run bin/server.dart

# Ou especificar porta customizada
PORT=9000 dart run bin/server.dart
```

O servidor estará disponível em `http://localhost:8081` (ou a porta especificada).

## 📡 API

### POST /compile

Compila código Flutter para bytecode.

**Request:**
```json
{
  "code": "import 'package:flutter/material.dart';\n\nclass HelloWidget ...",
  "lib": "hello",
  "className": "HelloWidget"
}
```

**Response (sucesso):**
```json
{
  "lib": "hello",
  "className": "HelloWidget",
  "bytecode": "AQAAAAIAAA...", // base64
  "size": 42150
}
```

**Response (erro):**
```json
{
  "error": "Erro ao compilar: ...",
  "details": "Stack trace..."
}
```

### GET /health

Health check do servidor.

**Response:**
```json
{
  "status": "ok",
  "service": "flutter-eval-compiler"
}
```

## 🧪 Testando

```bash
# Health check
curl http://localhost:8081/health

# Compilar código de exemplo
curl -X POST http://localhost:8081/compile \
  -H "Content-Type: application/json" \
  -d '{
    "code": "import '\''package:flutter/material.dart'\'';\n\nclass HelloWidget extends StatelessWidget {\n  const HelloWidget({Key? key}) : super(key: key);\n\n  @override\n  Widget build(BuildContext context) {\n    return const Text('\''Hello from bytecode!'\'');\n  }\n}",
    "lib": "hello",
    "className": "HelloWidget"
  }'
```

## 🔌 Integração com Sagittarius

No seu backend Sagittarius, você pode fazer uma requisição HTTP para este servidor:

```dart
final response = await http.post(
  Uri.parse('http://localhost:8081/compile'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'code': widgetCode,
    'lib': 'hello',
    'className': 'HelloWidget',
  }),
);

final result = jsonDecode(response.body);
final bytecode = result['bytecode']; // Base64 string
```

Depois, retorne o bytecode para o cliente Nebula.

## 🔌 Integração com Nebula (Cliente)

No cliente Flutter, use `RuntimeWidget` para executar o bytecode:

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';

// Receber bytecode do backend
final bytecodeBase64 = await fetchFromBackend();
final bytecodeBytes = base64Decode(bytecodeBase64);
final bytecode = ByteData.view(Uint8List.fromList(bytecodeBytes).buffer);

// Criar runtime
final runtime = Runtime([bytecode]);
runtime.addPlugin(flutterEvalPlugin);

// Executar e renderizar
final widget = runtime.executeLib(
  'hello',
  'HelloWidget',
  [$BuildContext(context)],
);

// Usar o widget
RuntimeWidget(runtime: runtime, widget: widget);
```

## 📦 Dependências

- **shelf**: ^1.4.2 - Framework HTTP
- **shelf_router**: ^1.1.4 - Roteamento de endpoints
- **flutter_eval**: ^0.8.1 - Compilação de código Flutter
- **dart_eval**: ^0.8.2 - Compilador de bytecode

## 🛠️ Desenvolvimento

```bash
# Adicionar novas dependências
flutter pub add <package>

# Atualizar dependências
flutter pub upgrade

# Analisar código
flutter analyze
```

## ⚙️ Configuração de Produção

Para produção, considere:

1. **HTTPS**: Use um reverse proxy (nginx, Caddy)
2. **Rate Limiting**: Limite requisições por IP
3. **Caching**: Cache bytecode de códigos frequentes
4. **Monitoramento**: Logs estruturados e métricas
5. **Containerização**: Docker para deploy consistente

## 📝 Notas Técnicas

- O bytecode `.evc` é **platform-agnostic** (funciona em qualquer plataforma)
- Tamanho típico: 20-100KB (6-30KB com gzip)
- Compilação leva ~100-500ms dependendo da complexidade
- Bytecode é **determinístico** (mesmo código = mesmo bytecode)
- Use base64 para transmitir bytecode via JSON/HTTP
