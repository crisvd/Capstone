import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:app_parking/login.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('LoginScreen Tests', () {
    testWidgets('Login successful with valid credentials',
        (WidgetTester tester) async {
      final client = MockClient();
      when(client.post(
        Uri.parse('https://api2.parkingtalcahuano.cl/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Your_Token', 200));

      // Enter valid credentials
      await tester.enterText(
          find.byType(TextFormField).first, 'co.silvae@duocuc.cl');
      await tester.enterText(find.byType(TextFormField).last, 'picopico');

      // Tap the login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(); // Wait for any animations to settle

      // Verify successful login (for example, by checking navigation or showing a success message)
      // ...
    });

    testWidgets('Login fails with invalid credentials',
        (WidgetTester tester) async {
      final client = MockClient();
      when(client.post(
        Uri.parse('https://api2.parkingtalcahuano.cl/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      // Enter invalid credentials
      await tester.enterText(find.byType(TextFormField).first, 'invalid_email');
      await tester.enterText(
          find.byType(TextFormField).last, 'invalid_password');

      // Tap the login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(); // Wait for any animations to settle

      // Verify login failure (for example, by checking for an error dialog or error message)
      // ...
    });
  });
}
