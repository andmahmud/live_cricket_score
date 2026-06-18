import 'package:flutter_test/flutter_test.dart';

import 'package:live_cricket_score/app.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const CricketApp());
    expect(find.text('Live Cricket Score'), findsNothing);
  });
}
