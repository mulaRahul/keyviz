// Copyright 2019 Google LLC
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
import 'dart:async';
import 'dart:ui';

import 'platform_window.dart';
import 'screen.dart';
import 'window_size_channel.dart';

/// Returns a list of [Screen]s for the current screen configuration.
///
/// It is possible for this list to be empty, if the machine is running in
/// a headless mode.
Future<List<Screen>> getScreenList() async {
  return await WindowSizeChannel.instance.getScreenList();
}

/// Returns the [Screen] showing the window that contains this Flutter instance.
///
/// If the window is not being displayed, returns null. If the window is being
/// displayed on multiple screens, the platform can return any of those screens.
Future<Screen?> getCurrentScreen() async {
  final windowInfo = await WindowSizeChannel.instance.getWindowInfo();
  return windowInfo.screen;
}

/// Returns information about the window containing this Flutter instance.
Future<PlatformWindow> getWindowInfo() async {
  return await WindowSizeChannel.instance.getWindowInfo();
}

/// Sets the frame of the window containing this Flutter instance, in
/// screen coordinates.
///
/// The platform may adjust the frame as necessary if the provided frame would
/// cause significant usability issues (e.g., a window with no visible portion
/// that can be used to move the window).
void setWindowFrame(Rect frame) async {
  WindowSizeChannel.instance.setWindowFrame(frame);
}

/// Sets the minimum [Size] of the window containing this Flutter instance.
void setWindowMinSize(Size size) async {
  WindowSizeChannel.instance.setWindowMinSize(size);
}

/// Sets the maximum [Size] of the window containing this Flutter instance.
void setWindowMaxSize(Size size) async {
  WindowSizeChannel.instance.setWindowMaxSize(size);
}

/// Sets the window title, as a [String], of the window containing this Flutter instance.
void setWindowTitle(String title) async {
  WindowSizeChannel.instance.setWindowTitle(title);
}

/// Shows or hides the window.
void setWindowVisibility({required bool visible}) async {
  WindowSizeChannel.instance.setWindowVisibility(visible: visible);
}

/// Sets the window title's represented [Uri], of the window containing this Flutter instance.
///
/// Only implemented for macOS. If the URL is a file URL, the
/// window shows an icon in its title bar.
void setWindowTitleRepresentedUrl(Uri url) async {
  WindowSizeChannel.instance.setWindowTitleRepresentedUrl(url);
}

/// Gets the minimum [Size] of the window containing this Flutter instance.
Future<Size> getWindowMinSize() async {
  return WindowSizeChannel.instance.getWindowMinSize();
}

/// Gets the maximum [Size] of the window containing this Flutter instance.
Future<Size> getWindowMaxSize() async {
  return WindowSizeChannel.instance.getWindowMaxSize();
}
