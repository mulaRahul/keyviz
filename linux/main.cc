#include "my_application.h"
#include <hid_listener/hid_listener_plugin.h>

int main(int argc, char** argv) {
  // hid_listener instance
  HidListener listener;

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
