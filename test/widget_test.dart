// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:port_casa/app.dart';

void main() {
  testWidgets('App smoke test - Login screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PortCasaApp());

    // Wait for animations to complete
    await tester.pumpAndSettle();

    // Verify that the login screen is displayed
    expect(find.text('Port de Casablanca'), findsOneWidget);
    expect(find.text('Gestion des Anomalies'), findsOneWidget);
    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
