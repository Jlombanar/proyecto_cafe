// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ecommer_app/main.dart';

void main() {
  testWidgets('Muestra el título y los mensajes de bienvenida', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Mi primera aplicación en Flutter'), findsOneWidget);
    expect(find.text(' Hola  mundo desde flutter'), findsOneWidget);
    expect(find.text(' Esta es mi primera aplicación en flutter'), findsOneWidget);
    expect(find.text(' Estoy emocionado de aprender flutter'), findsOneWidget);
  });
}
