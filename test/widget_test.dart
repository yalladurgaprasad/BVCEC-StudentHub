import 'package:flutter_test/flutter_test.dart';
import 'package:student_hub/main.dart';

void main() {
  testWidgets('SplashScreen renders StudentHub title and subtitle',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudentHubApp());

    // Verify splash screen components
    expect(find.text('BVCEC STUDENTHUB'), findsOneWidget);
    expect(
      find.text('Attendance & Performance Management System'),
      findsOneWidget,
    );

    // Pump past the 2.6s splash timer to navigate to login screen
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 900));

    // Verify transition to LoginScreen
    expect(find.text('Sign In to StudentHub'), findsOneWidget);
    expect(find.text('SELECT DEMO ACCOUNT ROLE'), findsOneWidget);
  });
}
