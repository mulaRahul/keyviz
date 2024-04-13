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
#include "include/window_size/window_size_plugin.h"

#include <Windows.h>
#include <flutter/flutter_view.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter_windows.h>

#include <codecvt>
#include <memory>
#include <optional>
#include <sstream>

namespace {

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

// See window_size_channel.dart for documentation.
const char kChannelName[] = "flutter/windowsize";
const char kGetScreenListMethod[] = "getScreenList";
const char kGetWindowInfoMethod[] = "getWindowInfo";
const char kSetWindowFrameMethod[] = "setWindowFrame";
const char kSetWindowMinimumSize[] = "setWindowMinimumSize";
const char kSetWindowMaximumSize[] = "setWindowMaximumSize";
const char kSetWindowTitleMethod[] = "setWindowTitle";
const char ksetWindowVisibilityMethod[] = "setWindowVisibility";
const char kFrameKey[] = "frame";
const char kVisibleFrameKey[] = "visibleFrame";
const char kScaleFactorKey[] = "scaleFactor";
const char kScreenKey[] = "screen";

const double kBaseDpi = 96.0;

// Returns a POINT corresponding to channel representation of a size.
POINT GetPointForPlatformChannelRepresentationSize(const EncodableList &size) {
  POINT point = {};
  point.x = static_cast<LONG>(std::get<double>(size[0]));
  point.y = static_cast<LONG>(std::get<double>(size[1]));
  return point;
}

// Returns the serializable form of |frame| expected by the platform channel.
EncodableValue GetPlatformChannelRepresentationForRect(const RECT &rect) {
  return EncodableValue(EncodableList{
      EncodableValue(static_cast<double>(rect.left)),
      EncodableValue(static_cast<double>(rect.top)),
      EncodableValue(static_cast<double>(rect.right) -
                     static_cast<double>(rect.left)),
      EncodableValue(static_cast<double>(rect.bottom) -
                     static_cast<double>(rect.top)),
  });
}

// Extracts information from monitor |monitor| and returns the
// serializable form expected by the platform channel.
EncodableValue GetPlatformChannelRepresentationForMonitor(HMONITOR monitor) {
  if (!monitor) {
    return EncodableValue();
  }

  MONITORINFO info;
  info.cbSize = sizeof(MONITORINFO);
  ::GetMonitorInfo(monitor, &info);
  UINT dpi = FlutterDesktopGetDpiForMonitor(monitor);
  double scale_factor = dpi / kBaseDpi;
  return EncodableValue(EncodableMap{
      {EncodableValue(kFrameKey),
       GetPlatformChannelRepresentationForRect(info.rcMonitor)},
      {EncodableValue(kVisibleFrameKey),
       GetPlatformChannelRepresentationForRect(info.rcWork)},
      {EncodableValue(kScaleFactorKey), EncodableValue(scale_factor)},
  });
}

BOOL CALLBACK MonitorRepresentationEnumProc(HMONITOR monitor, HDC hdc,
                                            LPRECT clip, LPARAM list_ref) {
  EncodableValue *monitors = reinterpret_cast<EncodableValue *>(list_ref);
  std::get<EncodableList>(*monitors).push_back(
      GetPlatformChannelRepresentationForMonitor(monitor));
  return TRUE;
}

// Extracts information from |window| and returns the serializable form expected
// by the platform channel.
EncodableValue GetPlatformChannelRepresentationForWindow(HWND window) {
  if (!window) {
    return EncodableValue();
  }
  RECT frame;
  ::GetWindowRect(window, &frame);
  HMONITOR window_monitor =
      ::MonitorFromWindow(window, MONITOR_DEFAULTTOPRIMARY);
  double scale_factor = FlutterDesktopGetDpiForHWND(window) / kBaseDpi;

  return EncodableValue(EncodableMap{
      {EncodableValue(kFrameKey),
       GetPlatformChannelRepresentationForRect(frame)},
      {EncodableValue(kScreenKey),
       GetPlatformChannelRepresentationForMonitor(window_monitor)},
      {EncodableValue(kScaleFactorKey), EncodableValue(scale_factor)},
  });
}

HWND GetRootWindow(flutter::FlutterView *view) {
  return ::GetAncestor(view->GetNativeWindow(), GA_ROOT);
}

class WindowSizePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  // Creates a plugin that communicates on the given channel.
  WindowSizePlugin(flutter::PluginRegistrarWindows *registrar);

  virtual ~WindowSizePlugin();

 private:
  // Called when a method is called on the plugin channel;
  void HandleMethodCall(const flutter::MethodCall<> &method_call,
                        std::unique_ptr<flutter::MethodResult<>> result);

  // Called for top-level WindowProc delegation.
  std::optional<LRESULT> HandleWindowProc(HWND hwnd, UINT message,
                                          WPARAM wparam, LPARAM lparam);

  // The registrar for this plugin, for accessing the window.
  flutter::PluginRegistrarWindows *registrar_;

  // The ID of the WindowProc delegate registration.
  int window_proc_id_ = -1;

  // The minimum size set by the platform channel.
  POINT min_size_ = {0, 0};

  // The maximum size set by the platform channel.
  POINT max_size_ = {-1, -1};
};

// static
void WindowSizePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel = std::make_unique<flutter::MethodChannel<>>(
      registrar->messenger(), kChannelName,
      &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<WindowSizePlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

WindowSizePlugin::WindowSizePlugin(flutter::PluginRegistrarWindows *registrar)
    : registrar_(registrar) {
  window_proc_id_ = registrar_->RegisterTopLevelWindowProcDelegate(
      [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
        return HandleWindowProc(hwnd, message, wparam, lparam);
      });
}

WindowSizePlugin::~WindowSizePlugin() {
  registrar_->UnregisterTopLevelWindowProcDelegate(window_proc_id_);
}

void WindowSizePlugin::HandleMethodCall(
    const flutter::MethodCall<> &method_call,
    std::unique_ptr<flutter::MethodResult<>> result) {
  if (method_call.method_name().compare(kGetScreenListMethod) == 0) {
    EncodableValue screens(std::in_place_type<EncodableList>);
    ::EnumDisplayMonitors(nullptr, nullptr, MonitorRepresentationEnumProc,
                          reinterpret_cast<LPARAM>(&screens));
    result->Success(screens);
  } else if (method_call.method_name().compare(kGetWindowInfoMethod) == 0) {
    result->Success(GetPlatformChannelRepresentationForWindow(
        GetRootWindow(registrar_->GetView())));
  } else if (method_call.method_name().compare(kSetWindowFrameMethod) == 0) {
    const auto *frame_list =
        std::get_if<EncodableList>(method_call.arguments());
    if (!frame_list || frame_list->size() != 4) {
      result->Error("Bad arguments", "Expected 4-element list");
      return;
    }
    // Frame validity (e.g., non-zero size) is assumed to be checked on the Dart
    // side of the call.
    int x = static_cast<int>(std::get<double>((*frame_list)[0]));
    int y = static_cast<int>(std::get<double>((*frame_list)[1]));
    int width = static_cast<int>(std::get<double>((*frame_list)[2]));
    int height = static_cast<int>(std::get<double>((*frame_list)[3]));
    ::SetWindowPos(GetRootWindow(registrar_->GetView()), nullptr, x, y, width,
                   height, SWP_NOACTIVATE | SWP_NOOWNERZORDER);
    result->Success();
  } else if (method_call.method_name().compare(kSetWindowMinimumSize) == 0) {
    const auto *size = std::get_if<EncodableList>(method_call.arguments());
    if (!size || size->size() != 2) {
      result->Error("Bad arguments", "Expected 2-element list");
      return;
    }
    min_size_ = GetPointForPlatformChannelRepresentationSize(*size);
    result->Success();
  } else if (method_call.method_name().compare(kSetWindowMaximumSize) == 0) {
    const auto *size = std::get_if<EncodableList>(method_call.arguments());
    if (!size || size->size() != 2) {
      result->Error("Bad arguments", "Expected 2-element list");
      return;
    }
    max_size_ = GetPointForPlatformChannelRepresentationSize(*size);
    result->Success();
  } else if (method_call.method_name().compare(kSetWindowTitleMethod) == 0) {
    const auto *title = std::get_if<std::string>(method_call.arguments());
    if (!title) {
      result->Error("Bad arguments", "Expected string");
      return;
    }
    std::wstring wstr =
        std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>, wchar_t>{}
            .from_bytes(*title);
    ::SetWindowText(GetRootWindow(registrar_->GetView()), wstr.c_str());
    result->Success();
  } else if (method_call.method_name().compare(ksetWindowVisibilityMethod) ==
             0) {
    const bool *visible = std::get_if<bool>(method_call.arguments());
    if (visible == nullptr) {
      result->Error("Bad arguments", "Expected bool");
      return;
    }
    ::ShowWindow(GetRootWindow(registrar_->GetView()),
                 *visible ? SW_SHOW : SW_HIDE);
    result->Success();
  } else {
    result->NotImplemented();
  }
}

std::optional<LRESULT> WindowSizePlugin::HandleWindowProc(HWND hwnd,
                                                          UINT message,
                                                          WPARAM wparam,
                                                          LPARAM lparam) {
  std::optional<LRESULT> result;
  switch (message) {
    case WM_GETMINMAXINFO:
      MINMAXINFO *info = reinterpret_cast<MINMAXINFO *>(lparam);
      // For the special "unconstrained" values, leave the defaults.
      if (min_size_.x != 0) info->ptMinTrackSize.x = min_size_.x;
      if (min_size_.y != 0) info->ptMinTrackSize.y = min_size_.y;
      if (max_size_.x != -1) info->ptMaxTrackSize.x = max_size_.x;
      if (max_size_.y != -1) info->ptMaxTrackSize.y = max_size_.y;
      result = 0;
      break;
  }
  return result;
}

}  // namespace

void WindowSizePluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  WindowSizePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
