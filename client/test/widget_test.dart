import 'package:flutter_test/flutter_test.dart';

import 'package:nebula/main.dart';

void main() {
  testWidgets('App should load HomePage', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is present
    expect(find.text('Widget Dinâmico'), findsOneWidget);

    // Verify that the buttons are present
    expect(
      find.text('Buscar Widget Pré-compilado do Server (HelloWorld)'),
      findsOneWidget,
    );
    expect(
      find.text('Compilar Código Digitado no Server e Renderizar'),
      findsOneWidget,
    );

    // Verify that the class name field is present
    expect(find.text('Nome da Classe'), findsOneWidget);
  });
}
