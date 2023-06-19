import 'package:flutter/material.dart';

import 'config/config.dart';
import 'windows/settings/settings.dart';

class KeyvizApp extends StatelessWidget {
  const KeyvizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Keyviz",
      theme: lightTheme,
      home: const Material(
        color: Colors.blueGrey,
        child: Center(child: SettingsWindow()),
      ),
    );
  }
}
