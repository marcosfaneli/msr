# Próximos Passos - Ideias de POC

Agora que temos o Hello World funcionando, aqui estão algumas ideias de POCs progressivas para explorar o `flutter_eval`:

## 1️⃣ POC Básica: Passagem de Argumentos

**Objetivo**: Passar dados do app host para o widget dinâmico

**Código a testar**:
```dart
// Widget dinâmico que recebe um nome
class Greeting extends StatelessWidget {
  Greeting(this.name);
  final String name;
  
  @override
  Widget build(BuildContext context) {
    return Text('Olá, $name!');
  }
}

// Chamada
EvalWidget(
  function: 'Greeting.',
  args: [$String('Marcos')],
  ...
)
```

## 2️⃣ POC Intermediária: Widget com Estado

**Objetivo**: Testar StatefulWidget dinâmico

**Código a testar**:
```dart
class Counter extends StatefulWidget {
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: Text('Incrementar'),
        ),
      ],
    );
  }
}
```

## 3️⃣ POC Avançada: Compilação Offline

**Objetivo**: Compilar código em arquivo .evc e carregar

**Passos**:
1. Criar arquivo separado com widget
2. Compilar com `dart_eval compile`
3. Adicionar .evc aos assets
4. Usar `RuntimeWidget` para carregar

## 4️⃣ POC Code Push Simulado

**Objetivo**: Simular update baixado do servidor

**Passos**:
1. Criar servidor local (pode ser `python -m http.server`)
2. Hospedar arquivo .evc
3. Usar `HotSwapLoader` com URL local
4. Testar atualização sem rebuild

## 5️⃣ POC Server-Driven UI

**Objetivo**: Código vem de API

**Passos**:
1. Criar endpoint que retorna código Dart como string
2. Fazer fetch do código
3. Usar `CompilerWidget` para compilar e renderizar
4. Testar mudanças no backend refletindo no app

## 6️⃣ POC Lista Dinâmica

**Objetivo**: Renderizar lista de widgets dinâmicos

**Código a testar**:
```dart
class DynamicList extends StatelessWidget {
  DynamicList(this.items);
  final List<String> items;
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: items.map((item) => 
        ListTile(title: Text(item))
      ).toList(),
    );
  }
}
```

## 7️⃣ POC Navegação

**Objetivo**: Testar navegação entre telas dinâmicas

**Recursos a explorar**:
- Navigator.push dentro de widget dinâmico
- Passar BuildContext
- Abrir telas também dinâmicas

## 8️⃣ POC Forms e Input

**Objetivo**: Capturar input do usuário

**Widgets a testar**:
- TextField
- TextEditingController
- Form validation
- Submit data back ao host

## 9️⃣ POC Temas e Estilos

**Objetivo**: Widgets dinâmicos respeitando tema

**A testar**:
- Acessar Theme.of(context)
- Usar cores do tema
- Dark/Light mode

## 🔟 POC Performance

**Objetivo**: Medir performance de compilação/execução

**Métricas**:
- Tempo de compilação (debug)
- Tempo de loading (bytecode)
- Memory footprint
- Frame rate durante uso

---

## Sugestão de Ordem

1. Comece pela **POC 1** (argumentos) - mais simples
2. Depois **POC 2** (estado) - fundamental
3. **POC 3** (compilação offline) - entender workflow
4. **POC 5** (server-driven) - caso de uso real
5. Demais POCs conforme necessidade

## Dicas

- Sempre teste em modo debug primeiro (compila na hora)
- Use hot restart após mudanças em strings de código
- Consulte widgets suportados na doc antes de tentar
- Guarde o arquivo .evc gerado para usar em release

---

**Pronto para começar?** Execute `flutter run` e veja o Hello World funcionando! 🚀
