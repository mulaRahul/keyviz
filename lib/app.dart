import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/key_event.dart';
import 'providers/key_style.dart';
import 'windows/error/error.dart';
import 'windows/settings/settings.dart';
import 'windows/key_visualizer/key_visualizer.dart';
import 'package:keyviz/windows/mouse_visualizer/mouse_visualizer.dart';

class KeyvizApp extends StatelessWidget {
  const KeyvizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Keyviz",
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: GestureDetector(
        onTap: _removePrimaryFocus,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => KeyEventProvider()),
            ChangeNotifierProvider(create: (_) => KeyStyleProvider()),
          ],
          child: const Material(
            type: MaterialType.transparency,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ErrorView(),
                KeyVisualizer(),
                SettingsWindow(),
                MouseVisualizer(),
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
