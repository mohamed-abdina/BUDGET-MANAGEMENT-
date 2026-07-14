import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerline_app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LedgerlineApp());
    await tester.pump();
  });
}
