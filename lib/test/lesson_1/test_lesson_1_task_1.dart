import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superheroes/main.dart';

import '../shared/test_helpers.dart';

const structure = <String, FileSystemEntityType>{
  "./google_fonts": FileSystemEntityType.directory,
  "./google_fonts/OpenSans-Bold.ttf": FileSystemEntityType.file,
  "./google_fonts/OpenSans-BoldItalic.ttf": FileSystemEntityType.file,
  "./google_fonts/OpenSans-ExtraBold.ttf": FileSystemEntityType.file,
  "./google_fonts/OpenSans-ExtraBoldItalic.ttf": FileSystemEntityType.file,
  "./google_fonts/OpenSans-Italic.ttf": FileSystemEntityType.file,
  "./google_fonts/OpenSans-Light.ttf": FileSystemEntityType.file,
  "./google_fonts/OpenSans-LightItalic.ttf": FileSystemEntityType.file,
  "./google_fonts/OpenSans-Regular.ttf": FileSystemEntityType.file,
  "./google_fonts/OpenSans-SemiBold.ttf": FileSystemEntityType.file,
  "./google_fonts/OpenSans-SemiBoldItalic.ttf": FileSystemEntityType.file,
};

void runTestLesson1Task1() {
  testWidgets('module1', (WidgetTester tester) async {
    testStructure(structure);

    await tester.pumpWidget(MyApp());

    final materialAppFinder = find.byType(MaterialApp);
    expect(
      materialAppFinder,
      findsOneWidget,
      reason: "There should be a MaterialApp widget in MyApp",
    );

    final MaterialApp materialApp = tester.widget<MaterialApp>(materialAppFinder);

    expect(
      materialApp.theme,
      isNotNull,
      reason: "You need to provide ThemeData in MaterialApp",
    );

    expect(
      materialApp.theme!.textTheme.bodyText1!.fontFamily,
      equals("OpenSans_regular"),
      reason: "Text theme should be equals to GoogleFonts.openSansTextTheme()",
    );
    
  });
}
