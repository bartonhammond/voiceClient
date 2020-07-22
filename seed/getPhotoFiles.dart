import 'dart:io';

List<dynamic> getFiles() {
  final files = <dynamic>[];
  final Directory dir = Directory('./seed/photos');
  // execute an action on each entry
  dir.listSync(recursive: true).forEach((f) {
    if (f.path.endsWith('jpg')) {
      files.add(f.path.toString());
    }
  });
  return files;
}
