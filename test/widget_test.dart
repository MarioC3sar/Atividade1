// Teste do widget principal do aplicativo de Localizações.

import 'package:atividade1/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atividade1/main.dart';

void main() {
  testWidgets('App inicializa e exibe a tela de coleta', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that the app title is displayed.
    expect(find.text('Localizações'), findsOneWidget);

    // Verify that the start button is displayed.
    expect(find.text('Iniciar coleta'), findsOneWidget);

    // Verify that the stop button is displayed.
    expect(find.text('Parar coleta'), findsOneWidget);
  });
}
