import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gafars_portfolio/features/auth/view/login_page.dart';
import 'package:gafars_portfolio/features/home/widgets/avatar_presets.dart';

void main() {
  test(
    'DiceBear adventurer URL uses api.dicebear.com and the adventurer style',
    () {
      final url = AvatarPresets.buildDiceBearUrl(
        fullName: 'Razak Gafar',
        email: 'razak@example.com',
      );

      expect(url, contains('https://api.dicebear.com'));
      expect(url, contains('/adventurer/png'));
      expect(url, contains('Razak%20Gafar'));
    },
  );

  test('DiceBear avatar options generate multiple adventurer choices', () {
    final options = AvatarPresets.buildDiceBearOptions(
      fullName: 'Razak Gafar',
      email: 'razak@example.com',
    );

    expect(options, hasLength(6));
    expect(options.first.url, contains('/adventurer/png'));
    expect(options.map((option) => option.seed).toSet(), hasLength(6));
  });

  testWidgets('Login page renders admin sign-in form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Admin Login'), findsOneWidget);
    expect(find.text('Sign in to manage your portfolio'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
  });
}
