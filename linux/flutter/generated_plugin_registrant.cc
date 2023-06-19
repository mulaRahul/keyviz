//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <hid_listener/hid_listener_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) hid_listener_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "HidListenerPlugin");
  hid_listener_plugin_register_with_registrar(hid_listener_registrar);
}
