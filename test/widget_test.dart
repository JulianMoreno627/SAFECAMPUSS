import 'package:flutter_test/flutter_test.dart';
import 'package:safecampus_ai/app.dart';

void main() {
  testWidgets('SafeCampus smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeCampusApp());
  });
}
