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
#include "include/window_size/window_size_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <cstring>

// See window_size_channel.dart for documentation.
const char kChannelName[] = "flutter/windowsize";
const char kBadArgumentsError[] = "Bad Arguments";
const char kNoScreenError[] = "No Screen";
const char kGetScreenListMethod[] = "getScreenList";
const char kGetWindowInfoMethod[] = "getWindowInfo";
const char kSetWindowFrameMethod[] = "setWindowFrame";
const char kSetWindowMinimumSizeMethod[] = "setWindowMinimumSize";
const char kSetWindowMaximumSizeMethod[] = "setWindowMaximumSize";
const char kSetWindowTitleMethod[] = "setWindowTitle";
const char ksetWindowVisibilityMethod[] = "setWindowVisibility";
const char kGetWindowMinimumSizeMethod[] = "getWindowMinimumSize";
const char kGetWindowMaximumSizeMethod[] = "getWindowMaximumSize";
const char kFrameKey[] = "frame";
const char kVisibleFrameKey[] = "visibleFrame";
const char kScaleFactorKey[] = "scaleFactor";
const char kScreenKey[] = "screen";

struct _FlWindowSizePlugin {
  GObject parent_instance;

  FlPluginRegistrar* registrar;

  // Connection to Flutter engine.
  FlMethodChannel* channel;

  // Requested window geometry.
  GdkGeometry window_geometry;
};

G_DEFINE_TYPE(FlWindowSizePlugin, fl_window_size_plugin, g_object_get_type())

// Gets the window being controlled.
GtkWindow* get_window(FlWindowSizePlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr) return nullptr;

  return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// Gets the display connection.
GdkDisplay* get_display(FlWindowSizePlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr) return nullptr;

  return gtk_widget_get_display(GTK_WIDGET(view));
}

// Converts frame dimensions into the Flutter representation.
FlValue* make_frame_value(gint x, gint y, gint width, gint height) {
  g_autoptr(FlValue) value = fl_value_new_list();

  fl_value_append_take(value, fl_value_new_float(x));
  fl_value_append_take(value, fl_value_new_float(y));
  fl_value_append_take(value, fl_value_new_float(width));
  fl_value_append_take(value, fl_value_new_float(height));

  return fl_value_ref(value);
}

// Converts monitor information into the Flutter representation.
FlValue* make_monitor_value(GdkMonitor* monitor) {
  g_autoptr(FlValue) value = fl_value_new_map();

  GdkRectangle frame;
  gdk_monitor_get_geometry(monitor, &frame);
  fl_value_set_string_take(
      value, kFrameKey,
      make_frame_value(frame.x, frame.y, frame.width, frame.height));

  gdk_monitor_get_workarea(monitor, &frame);
  fl_value_set_string_take(
      value, kVisibleFrameKey,
      make_frame_value(frame.x, frame.y, frame.width, frame.height));

  gint scale_factor = gdk_monitor_get_scale_factor(monitor);
  fl_value_set_string_take(value, kScaleFactorKey,
                           fl_value_new_float(scale_factor));

  return fl_value_ref(value);
}

// Gets the list of current screens.
static FlMethodResponse* get_screen_list(FlWindowSizePlugin* self) {
  g_autoptr(FlValue) screens = fl_value_new_list();

  GdkDisplay* display = get_display(self);
  if (display == nullptr) {
    return FL_METHOD_RESPONSE(
        fl_method_error_response_new(kNoScreenError, nullptr, nullptr));
  }

  gint n_monitors = gdk_display_get_n_monitors(display);
  for (gint i = 0; i < n_monitors; i++) {
    GdkMonitor* monitor = gdk_display_get_monitor(display, i);
    fl_value_append_take(screens, make_monitor_value(monitor));
  }

  return FL_METHOD_RESPONSE(fl_method_success_response_new(screens));
}

// Gets information about the Flutter window.
static FlMethodResponse* get_window_info(FlWindowSizePlugin* self) {
  GtkWindow* window = get_window(self);
  if (window == nullptr) {
    return FL_METHOD_RESPONSE(
        fl_method_error_response_new(kNoScreenError, nullptr, nullptr));
  }

  g_autoptr(FlValue) window_info = fl_value_new_map();

  gint x, y, width, height;
  gtk_window_get_position(window, &x, &y);
  gtk_window_get_size(window, &width, &height);
  fl_value_set_string_take(window_info, kFrameKey,
                           make_frame_value(x, y, width, height));

  // Get the monitor this window is inside, or the primary monitor if doesn't
  // appear to be in any.
  GdkDisplay* display = get_display(self);
  GdkMonitor* monitor_with_window = gdk_display_get_primary_monitor(display);
  int n_monitors = gdk_display_get_n_monitors(display);
  for (int i = 0; i < n_monitors; i++) {
    GdkMonitor* monitor = gdk_display_get_monitor(display, i);

    GdkRectangle frame;
    gdk_monitor_get_geometry(monitor, &frame);
    if ((x >= frame.x && x <= frame.x + frame.width) &&
        (y >= frame.y && y <= frame.y + frame.width)) {
      monitor_with_window = monitor;
      break;
    }
  }
  fl_value_set_string_take(window_info, kScreenKey,
                           make_monitor_value(monitor_with_window));

  gint scale_factor = gtk_widget_get_scale_factor(GTK_WIDGET(window));
  fl_value_set_string_take(window_info, kScaleFactorKey,
                           fl_value_new_float(scale_factor));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(window_info));
}

// Sets the window position and dimensions.
static FlMethodResponse* set_window_frame(FlWindowSizePlugin* self,
                                          FlValue* args) {
  if (fl_value_get_type(args) != FL_VALUE_TYPE_LIST ||
      fl_value_get_length(args) != 4) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new(
        kBadArgumentsError, "Expected 4-element list", nullptr));
  }
  double x = fl_value_get_float(fl_value_get_list_value(args, 0));
  double y = fl_value_get_float(fl_value_get_list_value(args, 1));
  double width = fl_value_get_float(fl_value_get_list_value(args, 2));
  double height = fl_value_get_float(fl_value_get_list_value(args, 3));

  GtkWindow* window = get_window(self);
  if (window == nullptr) {
    return FL_METHOD_RESPONSE(
        fl_method_error_response_new(kNoScreenError, nullptr, nullptr));
  }

  gtk_window_move(window, static_cast<gint>(x), static_cast<gint>(y));
  gtk_window_resize(window, static_cast<gint>(width),
                    static_cast<gint>(height));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

// Send updated window geometry to GTK.
static void update_window_geometry(FlWindowSizePlugin* self) {
  gtk_window_set_geometry_hints(
      get_window(self), nullptr, &self->window_geometry,
      static_cast<GdkWindowHints>(GDK_HINT_MIN_SIZE | GDK_HINT_MAX_SIZE));
}

// Sets the window minimum size.
static FlMethodResponse* set_window_minimum_size(FlWindowSizePlugin* self,
                                                 FlValue* args) {
  if (fl_value_get_type(args) != FL_VALUE_TYPE_LIST ||
      fl_value_get_length(args) != 2) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new(
        kBadArgumentsError, "Expected 2-element list", nullptr));
  }
  double width = fl_value_get_float(fl_value_get_list_value(args, 0));
  double height = fl_value_get_float(fl_value_get_list_value(args, 1));

  if (get_window(self) == nullptr) {
    return FL_METHOD_RESPONSE(
        fl_method_error_response_new(kNoScreenError, nullptr, nullptr));
  }

  if (width >= 0 && height >= 0) {
    self->window_geometry.min_width = static_cast<gint>(width);
    self->window_geometry.min_height = static_cast<gint>(height);
  }

  update_window_geometry(self);

  return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

// Sets the window maximum size.
static FlMethodResponse* set_window_maximum_size(FlWindowSizePlugin* self,
                                                 FlValue* args) {
  if (fl_value_get_type(args) != FL_VALUE_TYPE_LIST ||
      fl_value_get_length(args) != 2) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new(
        kBadArgumentsError, "Expected 2-element list", nullptr));
  }
  double width = fl_value_get_float(fl_value_get_list_value(args, 0));
  double height = fl_value_get_float(fl_value_get_list_value(args, 1));

  if (get_window(self) == nullptr) {
    return FL_METHOD_RESPONSE(
        fl_method_error_response_new(kNoScreenError, nullptr, nullptr));
  }

  self->window_geometry.max_width = static_cast<gint>(width);
  self->window_geometry.max_height = static_cast<gint>(height);

  // Flutter uses -1 as unconstrained, GTK doesn't have an unconstrained value.
  if (self->window_geometry.max_width < 0) {
    self->window_geometry.max_width = G_MAXINT;
  }
  if (self->window_geometry.max_height < 0) {
    self->window_geometry.max_height = G_MAXINT;
  }

  update_window_geometry(self);

  return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

// Sets the window title.
static FlMethodResponse* set_window_title(FlWindowSizePlugin* self,
                                          FlValue* args) {
  if (fl_value_get_type(args) != FL_VALUE_TYPE_STRING) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new(
        kBadArgumentsError, "Expected string", nullptr));
  }

  GtkWindow* window = get_window(self);
  if (window == nullptr) {
    return FL_METHOD_RESPONSE(
        fl_method_error_response_new(kNoScreenError, nullptr, nullptr));
  }
  gtk_window_set_title(window, fl_value_get_string(args));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

// Sets the window visibility.
static FlMethodResponse* set_window_visible(FlWindowSizePlugin* self,
                                          FlValue* args) {
  if (fl_value_get_type(args) != FL_VALUE_TYPE_BOOL) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new(
        kBadArgumentsError, "Expected bool", nullptr));
  }

  GtkWindow* window = get_window(self);
  if (window == nullptr) {
    return FL_METHOD_RESPONSE(
        fl_method_error_response_new(kNoScreenError, nullptr, nullptr));
  }
  if (fl_value_get_bool(args)) {
    gtk_widget_show(GTK_WIDGET(window));
  } else {
    gtk_widget_hide(GTK_WIDGET(window));
  }

  return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

// Gets the window minimum size.
static FlMethodResponse* get_window_minimum_size(FlWindowSizePlugin* self) {
  g_autoptr(FlValue) size = fl_value_new_list();

  gint min_width = self->window_geometry.min_width;
  gint min_height = self->window_geometry.min_height;

  // GTK uses -1 for the requisition size (the size GTK has calculated).
  // Report this as zero (smallest possible) so this doesn't look like Size(-1, -1).
  if (min_width < 0) {
    min_width = 0;
  }
  if (min_height < 0) {
    min_height = 0;
  }

  fl_value_append_take(size, fl_value_new_float(min_width));
  fl_value_append_take(size, fl_value_new_float(min_height));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(size));
}

// Gets the window maximum size.
static FlMethodResponse* get_window_maximum_size(FlWindowSizePlugin* self) {
  g_autoptr(FlValue) size = fl_value_new_list();

  gint max_width = self->window_geometry.max_width;
  gint max_height = self->window_geometry.max_height;

  // Flutter uses -1 as unconstrained, GTK doesn't have an unconstrained value.
  if (max_width == G_MAXINT) {
    max_width = -1;
  }
  if (max_height == G_MAXINT) {
    max_height = -1;
  }

  fl_value_append_take(size, fl_value_new_float(max_width));
  fl_value_append_take(size, fl_value_new_float(max_height));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(size));
}

// Called when a method call is received from Flutter.
static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  FlWindowSizePlugin* self = FL_WINDOW_SIZE_PLUGIN(user_data);

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  g_autoptr(FlMethodResponse) response = nullptr;
  if (strcmp(method, kGetScreenListMethod) == 0) {
    response = get_screen_list(self);
  } else if (strcmp(method, kGetWindowInfoMethod) == 0) {
    response = get_window_info(self);
  } else if (strcmp(method, kSetWindowFrameMethod) == 0) {
    response = set_window_frame(self, args);
  } else if (strcmp(method, kSetWindowMinimumSizeMethod) == 0) {
    response = set_window_minimum_size(self, args);
  } else if (strcmp(method, kSetWindowMaximumSizeMethod) == 0) {
    response = set_window_maximum_size(self, args);
  } else if (strcmp(method, kSetWindowTitleMethod) == 0) {
    response = set_window_title(self, args);
  } else if (strcmp(method, ksetWindowVisibilityMethod) == 0) {
    response = set_window_visible(self, args);
  } else if (strcmp(method, kGetWindowMinimumSizeMethod) == 0) {
    response = get_window_minimum_size(self);
  } else if (strcmp(method, kGetWindowMaximumSizeMethod) == 0) {
    response = get_window_maximum_size(self);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  g_autoptr(GError) error = nullptr;
  if (!fl_method_call_respond(method_call, response, &error))
    g_warning("Failed to send method call response: %s", error->message);
}

static void fl_window_size_plugin_dispose(GObject* object) {
  FlWindowSizePlugin* self = FL_WINDOW_SIZE_PLUGIN(object);

  g_clear_object(&self->registrar);
  g_clear_object(&self->channel);

  G_OBJECT_CLASS(fl_window_size_plugin_parent_class)->dispose(object);
}

static void fl_window_size_plugin_class_init(FlWindowSizePluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = fl_window_size_plugin_dispose;
}

static void fl_window_size_plugin_init(FlWindowSizePlugin* self) {
  self->window_geometry.min_width = -1;
  self->window_geometry.min_height = -1;
  self->window_geometry.max_width = G_MAXINT;
  self->window_geometry.max_height = G_MAXINT;
}

FlWindowSizePlugin* fl_window_size_plugin_new(FlPluginRegistrar* registrar) {
  FlWindowSizePlugin* self = FL_WINDOW_SIZE_PLUGIN(
      g_object_new(fl_window_size_plugin_get_type(), nullptr));

  self->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            kChannelName, FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->channel, method_call_cb,
                                            g_object_ref(self), g_object_unref);

  return self;
}

void window_size_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlWindowSizePlugin* plugin = fl_window_size_plugin_new(registrar);
  g_object_unref(plugin);
}
