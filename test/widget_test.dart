import 'package:flutter_test/flutter_test.dart';

import 'package:migra_ayuda/main.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());

    // Verify that the login screen loads
    expect(find.text('Migra Ayuda'), findsOneWidget);
    expect(find.text('Inicia sesión para continuar'), findsOneWidget);
  });
}
