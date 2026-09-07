import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warder_do_mobile/core/theme/app_theme.dart';
import 'package:warder_do_mobile/core/widgets/wd_button.dart';
import 'package:warder_do_mobile/core/widgets/wd_text_field.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('WdPrimaryButton', () {
    testWidgets('bosilganda callback ishlaydi', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _wrap(WdPrimaryButton(label: 'Kirish', onPressed: () => taps++)),
      );

      await tester.tap(find.text('Kirish'));
      expect(taps, 1);
    });

    testWidgets('isLoading holatida spinner chiqadi va bosilmaydi', (
      tester,
    ) async {
      var taps = 0;

      await tester.pumpWidget(
        _wrap(
          WdPrimaryButton(
            label: 'Kirish',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Kirish'), findsNothing);

      await tester.tap(find.byType(WdPrimaryButton));
      expect(taps, 0);
    });
  });

  group('WdTextField', () {
    testWidgets('parol maydoni ko’z tugmasi bilan ochiladi', (tester) async {
      final controller = TextEditingController(text: 'supersecret1');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          WdTextField(controller: controller, label: 'Parol', obscure: true),
        ),
      );

      EditableText editable() =>
          tester.widget<EditableText>(find.byType(EditableText));

      expect(editable().obscureText, isTrue);

      // Ko'z tugmasi — parol maydonidagi yagona IconButton (suffixIcon).
      // Ikonka endi HugeIcons SVG, shuning uchun `byIcon` emas `byType`.
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(editable().obscureText, isFalse);
    });

    testWidgets('serverdan kelgan xato maydon ostida ko’rinadi', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          WdTextField(
            controller: controller,
            label: 'Email',
            errorText: 'value is not a valid email address',
          ),
        ),
      );

      expect(find.text('value is not a valid email address'), findsOneWidget);
    });
  });
}
