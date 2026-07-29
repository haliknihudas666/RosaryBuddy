import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rosary/main.dart';

void main() {
  testWidgets('Rosary app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RosaryApp(),
      ),
    );
    expect(find.text('Santo Rosaryo'), findsOneWidget);
  });
}
