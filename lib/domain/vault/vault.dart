import 'package:flutter/material.dart';

import 'package:keyviz/config/extensions.dart';

import 'json.dart' as json;

const _configDataFile = "config.json";
const _styleDataFile = "style.json";

class Vault {
  const Vault._();

  static Future<Map<String, dynamic>?> loadConfigData() async {
    return await json.load(_configDataFile);
  }

  static Future<Map<String, dynamic>?> loadStyleData() async {
    return await json.load(_styleDataFile);
  }

  static save(BuildContext context) {
    json.dump(context.keyEvent.toJson, _configDataFile);
    json.dump(context.keyStyle.toJson, _styleDataFile);
  }
}
