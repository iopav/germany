import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:germany/core/widgets/app_shell_style.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bottom navigation svg assets load', (tester) async {
    const paths = [
      'assets/images/icons/icon-home.svg',
      'assets/images/icons/icon-home-filled.svg',
      'assets/images/icons/icon-reviews.svg',
      'assets/images/icons/icon-reviews-filled.svg',
      'assets/images/icons/icon-chat.svg',
      'assets/images/icons/icon-chat-filled.svg',
      'assets/images/icons/icon-settings.svg',
      'assets/images/icons/icon-settings-filled.svg',
    ];

    for (final path in paths) {
      final content = await rootBundle.loadString(path);
      expect(content, contains('<svg'));
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: 0,
                items: AppShellStyle.bottomNavigationItemsFor(context),
              ),
            );
          },
        ),
      ),
    );

    expect(find.byType(SvgPicture), findsWidgets);
  });
}
