// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart' as window_size;

void main() {
  // Try to resize and reposition the window to be half the width and height
  // of its screen, centered horizontally and shifted up from center.
  WidgetsFlutterBinding.ensureInitialized();
  window_size.getWindowInfo().then((window) {
    final screen = window.screen;
    if (screen != null) {
      final screenFrame = screen.visibleFrame;
      final width = math.max((screenFrame.width / 2).roundToDouble(), 800.0);
      final height = math.max((screenFrame.height / 2).roundToDouble(), 600.0);
      final left =
          screenFrame.left + ((screenFrame.width - width) / 2).roundToDouble();
      final top =
          screenFrame.top + ((screenFrame.height - height) / 3).roundToDouble();
      final frame = Rect.fromLTWH(left, top, width, height);
      window_size.setWindowFrame(frame);
      window_size.setWindowMinSize(Size(0.8 * width, 0.8 * height));
      window_size.setWindowMaxSize(Size(1.5 * width, 1.5 * height));
      window_size
          .setWindowTitle('window_size Example on ${Platform.operatingSystem}');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'window_size Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, Key? key}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _screens = <window_size.Screen>[];

  @override
  void initState() {
    super.initState();

    window_size.getScreenList().then(
          (screens) => setState(
            () => _screens.addAll(screens),
          ),
        );
  }

  void _incrementCounter() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox.square(
              dimension: 500,
              child: DecoratedBox(
                decoration: BoxDecoration(border: Border.all()),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final screen in _screens)
                      Positioned(
                        top: screen.frame.top / 10,
                        left: screen.frame.left / 10,
                        width: screen.frame.size.width / 10,
                        height: screen.frame.size.height / 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.primaries[math.Random().nextInt(4)],
                          ),
                          child: Text(screen.frame.size.toString()),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
