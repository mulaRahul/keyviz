import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<File> _file(String filePath) async {
  // local appdata directory
  final Directory appDir = await getApplicationDocumentsDirectory();
  // json file
  return File("${appDir.path}/$filePath");
}

// load Map from a json file
Future<Map<String, dynamic>?> load(String filePath) async {
  final File file = await _file(filePath);
  // file exists
  if (await file.exists()) {
    try {
      // read file content
      final String fileContent = await file.readAsString();
      // parse json
      return json.decode(fileContent);
    } catch (exception) {
      debugPrint(exception.toString());
    }
  }
  debugPrint("[ json:load ]: $file not found!");
  return null;
}

// dump/write Map to a json file
Future<void> dump(
  Map<String, dynamic> data,
  String filePath, {
  bool createFileIfNotFound = true,
}) async {
  final File file = await _file(filePath);
  // file exists
  if (await file.exists()) {
    await file.writeAsString(json.encode(data));
  } else if (createFileIfNotFound) {
    await file.create();
    await file.writeAsString(json.encode(data));
  }
}
