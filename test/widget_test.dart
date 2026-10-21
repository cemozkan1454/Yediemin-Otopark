import 'package:flutter_test/flutter_test.dart';
import 'package:yediemin_app/main.dart';

void main() {
  testWidgets('Ana ekran açılır ve ana menüleri gösterir', (tester) async {
    await tester.pumpWidget(const YedieminApp());

    expect(find.text('Yediemin Otopark'), findsOneWidget);
    expect(find.text('Yeni Araç'), findsOneWidget);
    expect(find.text('Araçlar'), findsNWidgets(2));
  });
}
