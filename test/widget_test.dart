import 'package:flutter_test/flutter_test.dart';
import 'package:flashscan/app.dart'; // Ensure package name wraps around if needed, but relative import might be safer or check pubspec name

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(cameras: []));

    // Verify that the title is present
    expect(find.text('FlashScan'), findsOneWidget);
  });
}
