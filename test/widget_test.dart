import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_app/main.dart';
import 'package:pomodoro_app/services/storage_service.dart';

void main() {
  testWidgets('PomoFocusApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();

    await tester.pumpWidget(PomoFocusApp(storageService: storageService));
    await tester.pumpAndSettle();

    // Verify title and main elements are rendered
    expect(find.text('PomoFocus Pro'), findsOneWidget);
    expect(find.text('Focus'), findsWidgets);
    expect(find.text('Short Break'), findsWidgets);
  });
}
