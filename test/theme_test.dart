import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kitcha_app/providers/recipe_provider.dart';
import 'package:kitcha_app/providers/analysis_provider.dart';
import 'package:kitcha_app/main.dart';
import 'package:kitcha_app/theme/app_theme.dart';

void main() {
  Widget createTestApp({Brightness brightness = Brightness.light}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark,
        home: const Scaffold(
          body: Center(
            child: Text('Theme Test'),
          ),
        ),
      ),
    );
  }

  group('Light Theme Tests', () {
    testWidgets('Light theme has correct primary color (Tomato Red)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(brightness: Brightness.light));
      
      final theme = Theme.of(tester.element(find.text('Theme Test')));
      expect(theme.colorScheme.primary, AppTheme.primaryColor);
    });

    testWidgets('Light theme has correct secondary color (Mint Green)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(brightness: Brightness.light));
      
      final theme = Theme.of(tester.element(find.text('Theme Test')));
      expect(theme.colorScheme.secondary, AppTheme.accentAI);
    });

    testWidgets('Light theme has Cream scaffold background', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(brightness: Brightness.light));
      
      final theme = Theme.of(tester.element(find.text('Theme Test')));
      expect(theme.scaffoldBackgroundColor, AppTheme.backgroundLight);
    });

    testWidgets('Light theme AppBar has Charcoal background', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(brightness: Brightness.light));
      
      final theme = Theme.of(tester.element(find.text('Theme Test')));
      expect(theme.appBarTheme.backgroundColor, AppTheme.backgroundDark);
    });
  });

  group('Dark Theme Tests', () {
    testWidgets('Dark theme has correct primary color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(brightness: Brightness.dark));
      
      final theme = Theme.of(tester.element(find.text('Theme Test')));
      expect(theme.colorScheme.primary, AppTheme.primaryColor);
    });

    testWidgets('Dark theme has Charcoal scaffold background', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(brightness: Brightness.dark));
      
      final theme = Theme.of(tester.element(find.text('Theme Test')));
      expect(theme.scaffoldBackgroundColor, AppTheme.backgroundDark);
    });

    testWidgets('Dark theme AppBar has Charcoal background', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(brightness: Brightness.dark));
      
      final theme = Theme.of(tester.element(find.text('Theme Test')));
      expect(theme.appBarTheme.backgroundColor, AppTheme.backgroundDark);
    });
  });
}

