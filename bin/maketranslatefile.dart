import 'dart:async';
import 'dart:io';

Future<void> main() async {
  /*
   'german',
    'hindi',
    'indonesian',
    'japanese',
    'korean',
    'portuguese',
    'russian',
    'spanish',
    */
  final translations = <dynamic>[
    {
      'type': 'chinese',
      'code': 'zh',
      'trans': <String>[],
    },
    {
      'type': 'german',
      'code': 'de',
      'trans': <String>[],
    },
    {
      'type': 'hindi',
      'code': 'hi',
      'trans': <String>[],
    },
    {
      'type': 'indonesian',
      'code': 'id',
      'trans': <String>[],
    },
    {
      'type': 'japanese',
      'code': 'ja',
      'trans': <String>[],
    },
    {
      'type': 'korean',
      'code': 'ko',
      'trans': <String>[],
    },
    {
      'type': 'portuguese',
      'code': 'pt',
      'trans': <String>[],
    },
    {
      'type': 'russian',
      'code': 'ru',
      'trans': <String>[],
    },
    {
      'type': 'spanish',
      'code': 'es',
      'trans': <String>[],
    },
  ];
  for (var lang in translations) {
    final List<String> translated =
        await readFileAsLines("lib/constants/translations/${lang['type']}.txt");
    lang['trans'] = translated;
  }

  final List<String> strings =
      await readFileAsLines('lib/constants/strings.dart');

  final cleanStrings = <String>[];

  for (var i = 0; i < strings.length; i++) {
    if (strings[i].contains('static const String')) {
      var parts = strings[i].trim().split(' ');
      cleanStrings.add(parts[3]);
    }
  }
  final File cleanFile = File('lib/constants/cleanFile.dart');
  if (await cleanFile.exists()) {
    await cleanFile.delete();
  }

  writeHeaders(cleanFile);
  for (var line = 0; line < cleanStrings.length; line++) {
    writeLine(cleanFile, '{');
    writeLine(cleanFile, "'en': Strings.${cleanStrings[line]},");
    for (var lang = 0; lang < translations.length; lang++) {
      writeLine(cleanFile, getLang(translations[lang], line));
    }

    writeLine(cleanFile, '} +');
  }

/*
  lines.forEach((String line) async {
    var parts = line.split("=");
    file.writeAsStringSync('${parts[1].trim()}\n', mode: FileMode.append);
  });
*/
  return;
}

String getLang(Map<String, dynamic> translation, int line) {
  return "'${translation["code"]}': '${translation["trans"][line]}',";
}

void writeLine(File cleanFile, String line) {
  cleanFile.writeAsStringSync('$line\n', mode: FileMode.append);
}

Future<List<String>> readFileAsLines(String path) async {
  return await File(path).readAsLines();
}

void writeHeaders(File cleanFile) {
  final List<String> headers = <String>[];
  headers.add("import 'package:i18n_extension/i18n_extension.dart';");
  headers.add("import 'package:voiceClient/constants/strings.dart';");
  headers.add('extension Localization on String {');

  headers.add("static final _t = Translations('en') +");

  headers.forEach((String line) async {
    cleanFile.writeAsStringSync('$line\n', mode: FileMode.append);
  });
}

void writeFooters(File cleanFile) {
  final List<String> footers = <String>[];
  footers.add('String get i18n => localize(this, _t);');
  footers
      .add('String fill(List<Object> params) => localizeFill(this, params);');
  footers.add('String plural(int value) => localizePlural(value, this, _t);');
  footers.add(
      'String version(Object modifier) => localizeVersion(modifier, this, _t);');
  footers.add(
      'Map<String, String> allVersions() => localizeAllVersions(this, _t);');
  footers.add('}');
  footers.forEach((String line) async {
    cleanFile.writeAsStringSync('$line\n', mode: FileMode.append);
  });
}
