import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'data/config.dart';
import 'key_listener.dart';
import 'data/keymaps.dart';
import 'providers/keyboard_event.dart';
import 'views/keycapture.dart';
import 'views/settings.dart';
import 'data/properties.dart';
import 'providers/config.dart';
import 'package:provider/provider.dart';

Future<void> prepareSettingsWindow() async {
  await windowManager.ensureInitialized();
  const WindowOptions windowOptions = WindowOptions(
    center: true,
    skipTaskbar: true,
    alwaysOnTop: true,
    size: Size(832, 640),
    title: "Keyviz Settings",
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAlignment(Alignment.center);
    await windowManager.setIgnoreMouseEvents(false);
    await windowManager.setFullScreen(false);
    await windowManager.setResizable(false);
    await windowManager.setHasShadow(true);
    await windowManager.show();
  });
}

Future<void> preparekeycaptureWindow() async {
  await windowManager.ensureInitialized();
  final WindowOptions windowOptions = WindowOptions(
    center: true,
    skipTaskbar: true,
    alwaysOnTop: true,
    titleBarStyle: TitleBarStyle.hidden,
    size: Size(configData.screenSize.width, configData.screenSize.height / 2),
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAlignment(Alignment.bottomRight);
    await windowManager.setIgnoreMouseEvents(true);
    await windowManager.setHasShadow(false);
    await windowManager.setAsFrameless();
    await windowManager.show();
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ? change the window to see-through with flutter_acrylic
  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.transparent,
    color: Colors.transparent,
  );
  // initialize
  initKeymaps();
  await configData.init();

  await preparekeycaptureWindow();
  // main app
  runApp(const RootApp());
}

class RootApp extends StatefulWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> with TrayListener {
  bool _configuring = false;
  late final GlobalKey<KeyboardEventListenerState> _listenerKey;

  bool get _listening => _listenerKey.currentState?.listening ?? false;

  @override
  void initState() {
    super.initState();
    _listenerKey = GlobalKey<KeyboardEventListenerState>();

    trayManager.addListener(this);
    initTray();
  }

  void initTray() async {
    await trayManager.setIcon("assets/img/tray.ico");
    await trayManager.setToolTip("Keyviz");
    await _setContextMenu();
  }

  Future<void> _setContextMenu() async {
    await trayManager.setContextMenu(
      Menu(
        items: <MenuItem>[
          MenuItem(
            label: _listening ? "❌ Turn Off" : "✔️ Turn On",
            toolTip: _listening
                ? "Stop displaying keystrokes"
                : "Display keystrokes",
            onClick: (_) {
              _listenerKey.currentState?.toggleListener();
              trayManager.setIcon(_listening
                  ? "assets/img/tray.ico"
                  : "assets/img/tray-bw.ico");
              _setContextMenu();
            },
          ),
          MenuItem(
            label: "Settings",
            toolTip: "Configure Keyviz",
            onClick: launchSettingsWindow,
          ),
          MenuItem.separator(),
          MenuItem(
            label: "Quit",
            toolTip: "Close Keyviz",
            onClick: (_) => windowManager.close(),
          ),
        ],
      ),
    );
  }

  void launchSettingsWindow(MenuItem _) async {
    await prepareSettingsWindow();
    configData.configuring = true;
    setState(() => _configuring = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        dialogBackgroundColor: veryDarkGrey,
        scrollbarTheme: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return darkGrey;
          }
          return Colors.transparent;
        })),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all<Color>(darkerGrey),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
        ),
      ),
      home: ChangeNotifierProvider(
        create: (_) => KeyboardEventProvider(),
        child: KeyboardEventListener(
          key: _listenerKey,
          child: _configuring
              ? ChangeNotifierProvider(
                  create: (_) => ConfigDataProvider(),
                  child: SettingsView(
                    exitSettings: () async {
                      await preparekeycaptureWindow();
                      _listenerKey.currentState?.refresh();
                      setState(() => _configuring = false);
                    },
                  ),
                )
              : const Scaffold(
                  backgroundColor: Colors.transparent,
                  body: KeycaptureView(),
                ),
        ),
      ),
    );
  }

  @override
  void onTrayIconMouseDown() {
    _configuring ? null : trayManager.popUpContextMenu();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
