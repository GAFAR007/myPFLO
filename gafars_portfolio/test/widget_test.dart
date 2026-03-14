import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gafars_portfolio/features/auth/view/login_page.dart';
import 'package:gafars_portfolio/features/home/widgets/avatar_presets.dart';

void main() {
  test(
    'DiceBear fallback URL uses api.dicebear.com and the avataaars style',
    () {
      final url = AvatarPresets.buildDiceBearUrl(
        fullName: 'Razak Gafar',
        email: 'razak@example.com',
      );

      expect(url, contains('https://api.dicebear.com'));
      expect(url, contains('/avataaars/png'));
      expect(url, contains('seed=Razak+Gafar'));
      expect(url, contains('top=dreads02'));
    },
  );

  test('DiceBear avatar options generate curated profile-fit choices', () {
    final options = AvatarPresets.buildProfileFitOptions(
      fullName: 'Razak Gafar',
      email: 'razak@example.com',
    );

    expect(options, hasLength(6));
    expect(options.first.url, contains('/avataaars/png'));
    expect(
      options.map((option) => option.label),
      containsAll(['Dreads + Glasses', 'Tech Lead', 'Focused Dev']),
    );
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
