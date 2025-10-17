# MSR

Sistema de compilação e execução dinâmica de widgets Flutter usando `flutter_eval` e `dart_eval`.

## 📋 O que é este projeto?

Este repositório demonstra um sistema completo de **widgets dinâmicos** no Flutter, permitindo compilar e executar código Flutter em tempo de execução, sem necessidade de recompilar o aplicativo. O projeto é dividido em duas partes principais:

### 🌟 Nebula (Cliente)
Aplicativo Flutter que executa widgets dinâmicos de duas formas:
1. **Widget pré-compilado**: Busca e executa o widget padrão já compilado no servidor
2. **Compilação sob demanda**: Envia código personalizado para o servidor compilar e depois executa o bytecode retornado

**Recursos**:
- Interface intuitiva com campo de texto para editar código Dart/Flutter
- Campo para especificar o nome da classe do widget
- Dois botões para diferentes modos de execução
- Feedback visual durante compilação e erros

### 🚀 Server (Servidor de Compilação)
Servidor HTTP Flutter que:
- Compila código Flutter para bytecode usando `flutter_eval`
- Expõe endpoints REST para compilação sob demanda
- Retorna bytecode em formato base64 pronto para execução
- Suporta compilação de código customizado ou widget padrão

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────┐
│                  NEBULA (Cliente)                   │
│                                                     │
│  1. Buscar Widget Pré-compilado (HelloWorld)        │
│     - Servidor retorna bytecode pronto              │
│                                                     │
│  2. Compilar Código Customizado                     │
│     - Usuário edita código e nome da classe         │
│     - Cliente envia para servidor compilar          │
│     - Servidor retorna bytecode                     │
│                                                     │
│  3. Executar Bytecode                               │
│     - Cria Runtime a partir do bytecode             │
│     - Renderiza widget dinamicamente                │
│                                                     │
└────────────────────┬────────────────────────────────┘
                     │
                     │ HTTP (porta 8081)
                     │ POST /compile
                     │ POST /execute
                     │
                     ▼
          ┌──────────────────────────┐
          │   SERVER (Compilador)    │
          │                          │
          │  - Compila código Dart   │
          │  - Usa flutter_eval      │
          │  - Retorna bytecode      │
          │    em base64             │
          └──────────────────────────┘
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
│   │   ├── home_page.dart    # Interface principal com UI
│   │   └── service.dart      # Serviço HTTP para comunicação com servidor
│   ├── test/
│   │   └── widget_test.dart  # Testes do aplicativo
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

## ✨ Funcionalidades Principais

### Interface do Nebula
- 📝 **Editor de código**: Campo de texto expansível para editar código Flutter/Dart
- 🏷️ **Campo de classe**: Especifique o nome da classe do widget a ser compilado
- 🟢 **Botão Verde**: Busca e executa widget pré-compilado do servidor
- 🔵 **Botão Azul**: Compila código customizado no servidor e renderiza
- 📊 **Área de preview**: Visualização do widget renderizado em tempo real
- ⚠️ **Tratamento de erros**: Feedback visual de erros de compilação ou execução

### Fluxo de Trabalho
1. Edite o código Flutter no editor
2. Especifique o nome da classe
3. Clique em compilar
4. Aguarde a compilação no servidor
5. Veja o widget renderizado instantaneamente

## 📖 Como Usar

### Opção 1: Buscar Widget Pré-compilado do Server
1. Clique no botão **"Buscar Widget Pré-compilado do Server (HelloWorld)"** (verde)
2. O app faz uma requisição POST para `http://localhost:8081/execute`
3. O servidor compila o widget padrão (`hello_widget.dart`) e retorna bytecode
4. O app executa o bytecode e renderiza o widget

### Opção 2: Compilar Código Customizado no Server
1. **Digite ou edite o código Flutter** no campo de texto grande
2. **Informe o nome da classe** no campo "Nome da Classe" (ex: `HelloWorld`, `Counter`, `MyWidget`)
3. Clique no botão **"Compilar Código Digitado no Server e Renderizar"** (azul)
4. O app envia o código e nome da classe para `http://localhost:8081/compile`
5. O servidor compila o código e retorna o bytecode
6. O app executa o bytecode e renderiza o widget compilado

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

**Outro exemplo - Widget com estado**:
```dart
import 'package:flutter/material.dart';

class Counter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Contador Widget', style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        Icon(Icons.add_circle, size: 48, color: Colors.blue),
      ],
    );
  }
}
```

> **Importante**: Certifique-se de que o nome da classe no campo corresponde ao nome da classe no código!

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

[EXECUTE] Iniciando compilação do hello_widget padrão
[EXECUTE] Código carregado (XXX caracteres)
[EXECUTE] Compilação concluída! Bytecode: XXX bytes
```

### Verificar logs do cliente:
```bash
# Os logs aparecem no terminal do Nebula
[COMPILE SERVER] Enviando código para compilação no servidor
[COMPILE SERVER] Código: XXX caracteres
[COMPILE SERVER] Classe: HelloWorld
[COMPILE SERVER] Resposta recebida: bytecode compilado
[COMPILE SERVER] Bytecode decodificado: XXX bytes
[COMPILE SERVER] Runtime criado com sucesso!

[SERVER] Resposta recebida: {...}
[SERVER] Decodificando bytecode (XXX chars)
[SERVER] Runtime criado com sucesso!
```

## 🧪 Testando

### Testar o servidor via curl:
```bash
# Health check
curl http://localhost:8081/health

# Executar widget padrão (HelloWorld)
curl -X POST http://localhost:8081/execute

# Compilar código customizado
curl -X POST http://localhost:8081/compile \
  -H "Content-Type: application/json" \
  -d '{
    "code": "import '\''package:flutter/material.dart'\'';\n\nclass MyWidget extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    return Text('\''Meu Widget Custom'\'', style: TextStyle(fontSize: 20));\n  }\n}",
    "lib": "mfaneli",
    "className": "MyWidget"
  }'

# Outro exemplo - Counter widget
curl -X POST http://localhost:8081/compile \
  -H "Content-Type: application/json" \
  -d '{
    "code": "import '\''package:flutter/material.dart'\'';\n\nclass Counter extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    return Column(children: [Text('\''Counter'\''), Icon(Icons.add)]);\n  }\n}",
    "lib": "mfaneli",
    "className": "Counter"
  }'
```

### Testar no aplicativo Nebula:
1. **Teste básico**: Use o botão verde para buscar o widget padrão
2. **Teste customizado**: Edite o código, ajuste o nome da classe, e clique no botão azul
3. **Teste de erro**: Tente compilar código inválido para ver o tratamento de erros

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
