import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_parking/main.dart'; // Asegúrate de que esto apunte a tu archivo principal

void main() {
  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Nombre de usuario'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Can enter username and password', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    await tester.enterText(
        find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');

    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('password'), findsOneWidget);
  });
}
