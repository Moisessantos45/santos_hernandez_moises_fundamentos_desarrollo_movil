import 'package:flutter_test/flutter_test.dart';
import 'package:maply/main.dart';

void main() {
  testWidgets('App basic initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaplyApp());
    expect(find.byType(MaplyApp), findsOneWidget);
  });
}
