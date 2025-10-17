# Resumo da Tecnologia flutter_eval

## O que é

`flutter_eval` é uma biblioteca Flutter que permite executar código Dart/Flutter dinamicamente em runtime usando um interpretador de bytecode customizado.

## Principais Casos de Uso

1. **Code Push / Hot Updates** - Atualizar partes do app sem republicar na loja
2. **Server-Driven UI** - Carregar interfaces do servidor dinamicamente
3. **Dynamic Widgets** - Criar widgets baseados em strings de código
4. **User Scripting** - Apps tipo calculadora ou "learn to code"

## Como Funciona

### Fluxo Básico

```
Código Dart (String) → Compilador dart_eval → Bytecode EVC → Interpretador → Widget Renderizado
```

### Dois Modos de Operação

1. **Modo Debug/Development**:
   - Compila string de código em runtime
   - Mais lento (~0.1s)
   - Útil para desenvolvimento rápido

2. **Modo Release/Production**:
   - Carrega bytecode pré-compilado (.evc)
   - Muito mais rápido
   - Bytecode é multiplataforma

## Componentes Principais

### Widgets Helpers

1. **`EvalWidget`** - Automático (compila em debug, carrega em release)
2. **`CompilerWidget`** - Sempre compila (útil para apps interativos)
3. **`RuntimeWidget`** - Sempre carrega bytecode (para apps em produção)
4. **`HotSwapLoader`** + **`HotSwap`** - Para code push OTA

### Compilação

```bash
# Instalar CLI
dart pub global activate dart_eval

# Compilar código
dart_eval compile -o output.evc
```

## Suporte de Widgets

### Widgets Suportados (parcial)
- Básicos: Container, Column, Row, Center, Text, Icon
- Material: Scaffold, AppBar, TextButton, ElevatedButton, Card
- Layout: Padding, Stack, Positioned, SizedBox, AspectRatio
- Input: TextField, GestureDetector
- Navigation: Navigator
- E muitos mais...

### Limitações
- Nem todos os widgets do Flutter são suportados
- Algumas features do Dart podem não funcionar
- Código existente pode precisar de adaptações

## Segurança

- Modelo de execução seguro herdado do `dart_eval`
- Acesso restrito a filesystem, network e APIs sensíveis por padrão
- Permissões podem ser concedidas via `MethodChannelPermission`

## Arquitetura para Code Push

```
App Principal
├── HotSwapLoader (aponta para URL do update)
└── HotSwap widgets (ID: #myWidget)
    └── childBuilder (fallback se update falhar)

Pacote de Update Separado
├── .dart_eval/bindings/flutter_eval.json
└── lib/hot_update.dart
    └── @RuntimeOverride('#myWidget')
        └── Widget myWidgetUpdate()
```

Compilar: `dart_eval compile -o version_xxx.evc`
Upload para servidor e app baixa automaticamente

## Estratégias de Loading

- **immediate** - Aplica update imediatamente (padrão debug)
- **cache** - Baixa e aplica na próxima inicialização
- **cacheApplyOnRestart** - Baixa agora, aplica no próximo restart (padrão release)

## Tamanho do App

Impacto mínimo:
- Flutter Counter: +1.4 MB
- Flutter Gallery: +0.4 MB
- Bytecode EVC: 20-100KB (6-30KB comprimido)

## Passagem de Argumentos

Ao chamar funções/construtores externamente:
- Especificar TODOS argumentos (inclusive opcionais) em ordem
- Usar `null` para indicar ausência (vs `$null()` para valor null)
- Usar wrappers: `$String()`, `$int()`, `$BuildContext.wrap()`, etc.

Exemplo:
```dart
RuntimeWidget(
  function: 'MyWidget.',
  args: [$String('nome'), null, $int(42)]
)
```

## Performance

- Compilador é muito rápido: ~0.1s para programas simples
- Bytecode EVC comprime muito bem (~4x com gzip)
- Execução via interpretador é rápida o suficiente para UI

## Recursos Adicionais

- [Documentação oficial](https://pub.dev/packages/flutter_eval)
- [Repositório GitHub](https://github.com/ethanblake4/flutter_eval)
- [Exemplo Code Push](https://github.com/ethanblake4/flutter_eval/tree/master/examples/code_push_app)
- [EvalPad - Playground Web](https://ethanblake.xyz/evalpad)

## Considerações

✅ **Quando Usar:**
- Apps que precisam de updates frequentes sem app store review
- UIs completamente dinâmicas
- Experimentação de features A/B testing
- Apps de automação/scripting

❌ **Quando NÃO Usar:**
- Código extremamente complexo ou crítico
- Quando precisa de 100% das features do Flutter
- Performance é absolutamente crítica
- App inteiro (use apenas para partes específicas)
