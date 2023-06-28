import 'package:flutter/material.dart';
import 'package:keyviz/windows/mouse_visualizer/mouse_visualizer.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/providers/key_event.dart';
import 'package:keyviz/providers/key_style.dart';

import 'config/config.dart';
import 'windows/settings/settings.dart';
import 'windows/key_visualizer/key_visualizer.dart';

class KeyvizApp extends StatelessWidget {
  const KeyvizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Keyviz",
      theme: lightTheme,
      home: GestureDetector(
        onTap: _removePrimaryFocus,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => KeyEventProvider()),
            ChangeNotifierProvider(create: (_) => KeyStyleProvider()),
          ],
          child: const Material(
            type: MaterialType.transparency,
            // color: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MouseVisualizer(),
                KeyVisualizer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _removePrimaryFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
