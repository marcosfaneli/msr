# MSR - Flutter Eval Project

Sistema de compilação e execução dinâmica de widgets Flutter usando `flutter_eval` e `dart_eval`.

## 📋 O que é este projeto?

Este repositório demonstra um sistema completo de **widgets dinâmicos** no Flutter, permitindo compilar e executar código Flutter em tempo de execução, sem necessidade de recompilar o aplicativo. O projeto é dividido em duas partes principais:

### 🌟 Nebula (Cliente)
Aplicativo Flutter que executa widgets dinâmicos de três formas:
1. **Compilação local**: Compila e executa código Dart/Flutter digitado diretamente no app
2. **Servidor remoto (Sagittarius)**: Busca widgets de um servidor externo (porta 8080)
3. **Servidor de compilação local**: Busca bytecode pré-compilado do servidor local (porta 8081)

### 🚀 Server (Servidor de Compilação)
Servidor HTTP Flutter que:
- Compila código Flutter para bytecode usando `flutter_eval`
- Expõe endpoints REST para compilação sob demanda
- Retorna bytecode em formato base64 pronto para execução

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────┐
│                    NEBULA (Cliente)                  │
│  - Compila código localmente                        │
│  - Conecta com servidor remoto (Sagittarius)        │
│  - Conecta com servidor de compilação local         │
└──────────────┬──────────────────────┬────────────────┘
               │                      │
               │ HTTP                 │ HTTP
               │ (8080)              │ (8081)
               │                      │
               ▼                      ▼
    ┌──────────────────┐   ┌──────────────────────┐
    │   Sagittarius    │   │   SERVER (Local)     │
    │  (Servidor       │   │  - Compila widgets   │
    │   Externo)       │   │  - Retorna bytecode  │
    └──────────────────┘   └──────────────────────┘
```

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework principal
- **dart_eval**: Compilador Dart para bytecode
- **flutter_eval**: Plugin que permite usar APIs do Flutter em código dinâmico
- **shelf**: Framework HTTP para o servidor
- **shelf_router**: Roteamento HTTP
- **http**: Cliente HTTP para requisições

## 📦 Estrutura do Projeto

```
msr/
├── nebula/                    # Aplicativo cliente Flutter
│   ├── lib/
│   │   ├── main.dart         # Entry point do app
│   │   ├── home_page.dart    # Interface principal
│   │   ├── service.dart      # Serviço para Sagittarius (porta 8080)
│   │   └── server_service.dart # Serviço para servidor local (porta 8081)
│   └── pubspec.yaml          # Dependências do cliente
│
└── server/                    # Servidor de compilação
    ├── lib/
    │   └── main.dart         # Servidor HTTP com endpoints
    ├── bin/
    │   └── hello_widget.dart # Widget exemplo para compilação
    └── pubspec.yaml          # Dependências do servidor
```

## 🚀 Como Rodar

### Pré-requisitos

- Flutter SDK (versão 3.8.1 ou superior)
- Dart SDK (versão 3.8.1 ou superior)

### 1. Instalar Dependências

#### Servidor
```bash
cd server
flutter pub get
```

#### Cliente (Nebula)
```bash
cd nebula
flutter pub get
```

### 2. Iniciar o Servidor de Compilação

```bash
cd server
flutter run -d linux  # ou -d macos, -d windows
```

O servidor irá iniciar na porta **8081** com os seguintes endpoints:

- `POST /compile` - Compila código Flutter customizado
- `POST /execute` - Compila o widget padrão (hello_widget.dart)
- `GET /health` - Health check

### 3. Iniciar o Cliente Nebula

Em outro terminal:

```bash
cd nebula
flutter run -d linux  # ou -d macos, -d windows
```

## 📖 Como Usar

### Opção 1: Compilação Local
1. Digite código Flutter válido no campo de texto
2. O código será compilado localmente usando `flutter_eval`
3. O widget será renderizado imediatamente

**Exemplo de código**:
```dart
import 'package:flutter/material.dart';

class HelloWorld extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello, World!', style: TextStyle(fontSize: 24));
  }
}
```

### Opção 2: Executar Widget do Server (HelloWorld)
1. Clique no botão **"Executar Widget do Server (HelloWorld)"**
2. O app faz uma requisição POST para `http://localhost:8081/execute`
3. O servidor compila o widget padrão e retorna bytecode
4. O app executa o bytecode e renderiza o widget

### Opção 3: Widget Remoto (Sagittarius)
1. Clique no botão **"Executar Widget Remoto (Sagittarius)"**
2. O app busca o código de um servidor externo (porta 8080)
3. Compila localmente e renderiza

> **Nota**: Para usar esta opção, você precisa ter um servidor rodando na porta 8080 que retorne código Flutter no formato esperado.

## 🔌 API do Servidor

### POST /compile
Compila código Flutter customizado.

**Request**:
```json
{
  "code": "import 'package:flutter/material.dart';\n\nclass MyWidget...",
  "lib": "mylib",
  "className": "MyWidget"
}
```

**Response**:
```json
{
  "lib": "mylib",
  "className": "MyWidget",
  "bytecode": "base64_encoded_bytecode...",
  "size": 1234
}
```

### POST /execute
Compila o widget padrão (hello_widget.dart).

**Response**:
```json
{
  "lib": "mfaneli",
  "className": "HelloWorld",
  "bytecode": "base64_encoded_bytecode...",
  "size": 1234
}
```

### GET /health
Health check do servidor.

**Response**:
```json
{
  "status": "ok",
  "service": "flutter-eval-compiler"
}
```

## 🎯 Casos de Uso

Este projeto demonstra conceitos de:

1. **Code Push**: Atualizar UI sem recompilar o app
2. **Server-Driven UI**: Interface controlada pelo backend
3. **Dynamic Widgets**: Criar widgets em tempo de execução
4. **Remote Compilation**: Compilar código em servidor separado
5. **Hot Updates**: Atualizar partes do app sem publicar nova versão

## ⚠️ Limitações

- Nem todas as APIs do Flutter são suportadas pelo `flutter_eval`
- Performance de widgets dinâmicos é inferior a widgets compilados nativamente
- Debugging de código dinâmico é mais complexo
- Requer conexão com servidor para algumas funcionalidades

## 🔍 Debugging

### Verificar logs do servidor:
```bash
# Os logs aparecem no terminal onde o servidor está rodando
[COMPILE] Iniciando compilação para lib:ClassName
[COMPILE] Código recebido (XXX caracteres)
[COMPILE] Compilação concluída! Bytecode: XXX bytes
```

### Verificar logs do cliente:
```bash
# Os logs aparecem no terminal do Nebula
[SERVER] Resposta recebida: {...}
[SERVER] Decodificando bytecode (XXX chars)
[SERVER] Runtime criado com sucesso!
```

## 🧪 Testando

### Testar o servidor via curl:
```bash
# Health check
curl http://localhost:8081/health

# Executar widget padrão
curl -X POST http://localhost:8081/execute

# Compilar código customizado
curl -X POST http://localhost:8081/compile \
  -H "Content-Type: application/json" \
  -d '{
    "code": "import '\''package:flutter/material.dart'\'';\n\nclass Test extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    return Text('\''Test'\'');\n  }\n}",
    "lib": "test",
    "className": "Test"
  }'
```

## 📚 Recursos Adicionais

- [Documentação flutter_eval](https://pub.dev/packages/flutter_eval)
- [Documentação dart_eval](https://pub.dev/packages/dart_eval)
- [Próximos Passos](nebula/PROXIMOS_PASSOS.md) - Ideias de POCs para explorar

## 🤝 Contribuindo

Sinta-se à vontade para explorar, modificar e experimentar com o código!

## 📝 Licença

Este é um projeto de demonstração/estudo.

---

**Desenvolvido com ❤️ usando Flutter e dart_eval**
