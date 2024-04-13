# window_size

This plugin allows resizing and repositioning the window containing the Flutter
content, as well as querying screen information.

This is a prototype, and in the long term is expected to be replaced by
[functionality within the Flutter
framework](https://flutter.dev/go/desktop-multi-window-support).

## Scope

There are currently no plans to add new functionality, such as window
minimization and maximization, to this plugin. The goals of this plugin were to:
- unblock certain core use cases among very early adopters, and
- validate plugin APIs in Flutter itself during early development of the desktop
  plugin APIs.

Now that those goals have been met, and the plugin APIs have been stabilized
such that anyone can create and publish desktop Flutter plugins, new functionality
will likely only be added here if unblocks a [Flutter top-tier
customer](https://github.com/flutter/flutter/wiki/Issue-hygiene#customers).
The community is encouraged to create their own plugins for other window
manipulation features.

## Supported Platforms

- [x] macOS
- [x] Windows
- [x] Linux

Not all operations have been implemented on all platforms, but the core functionality
of resizing and repositioning is available for all three.

## Use

See [the plugin README](../README.md) for general instructions on using FDE plugins.

### Linux

Requires GTK 3.22 or later.
