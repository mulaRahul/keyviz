import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

// TODO: add comments
void main() async {
  // ensure flutter plugins are intialized and ready to use
  WidgetsFlutterBinding.ensureInitialized();
  // make the window overlay above others
  await _initWindow();

  runApp(const KeyvizApp());
}

_initWindow() async {
  // make window see through
  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.transparent,
    color: Colors.transparent,
  );

  // customize window properties
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow(
    const WindowOptions(
      center: true,
      fullScreen: true,
      skipTaskbar: true,
      alwaysOnTop: true,
      titleBarStyle: TitleBarStyle.hidden,
    ),
    () async {
      await windowManager.setIgnoreMouseEvents(true);
      await windowManager.setHasShadow(false);
      await windowManager.setAsFrameless();
      await windowManager.show();
    },
  );
}
