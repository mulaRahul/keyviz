//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import hid_listener
import macos_window_utils
import screen_retriever
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  HidListenerPlugin.register(with: registry.registrar(forPlugin: "HidListenerPlugin"))
  MacOSWindowUtilsPlugin.register(with: registry.registrar(forPlugin: "MacOSWindowUtilsPlugin"))
  ScreenRetrieverPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
