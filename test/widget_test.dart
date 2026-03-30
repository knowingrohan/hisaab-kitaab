import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/app.dart';

void main() {
  testWidgets('App renders with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HisaabKitaabApp(),
      ),
    );

    expect(find.text('Hisaab Kitaab'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Entry'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
  });
}
