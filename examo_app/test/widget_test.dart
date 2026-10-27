import 'package:flutter_test/flutter_test.dart';

import 'package:examo_app/main.dart';

void main() {
  testWidgets('App boots on the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ExamoApp());
    expect(find.text('Examo'), findsWidgets);
  });
}
