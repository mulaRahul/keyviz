import 'package:flutter/material.dart' hide KeyEvent;
import 'package:keyviz/models/raw_keyboard_data.dart';
import 'package:keyviz/widgets/wrapper.dart';

import '../data/keymaps.dart';
import '../data/config.dart';
import '../data/properties.dart';

class KeyboardEventProvider extends ChangeNotifier {
  // ? [vkName]
  final List<String> _down = [];
  // ? Map<vkName, Widget>
  final Map<String, Animatedkeyviz> _widgets = {};
  // ? Map<vkName, Key>
  final Map<String, GlobalKey<AnimatedkeyvizState>> _janitor = {};
  // ? vkName
  String _lastPressed = "";

  bool has(String vkName) => _down.contains(vkName);
  List<Widget> get widgets => _widgets.values.toList();

  void add(String vkName, int id) async {
    // * hotkey filter
    final bool pressedHotKey = isHotkey(vkName);
    if (configData.filterHotkeys && !pressedHotKey) return;

    late bool onlySymbol;
    late bool skipTransition;
    final RawKeyboardData rawKeyData = RawKeyboardData(vkName);

    // * widget already in display
    if (_widgets.containsKey(vkName)) {
      _down.add(vkName);
      _janitor[vkName]?.currentState?.press();
      _janitor[vkName]?.currentState?.id = id;

      if (_down.length == 1 && pressedHotKey) {
        for (final String key in _widgets.keys.toList(growable: false)) {
          key == vkName ? null : _removeWithoutAnimation(key);
        }
      }

      return;
    }

    // * replace new key
    if (configData.replaceNew && _widgets.isNotEmpty) {
      if (pressedHotKey &&
          modifiers.containsKey(_widgets.keys.first) &&
          _down.isNotEmpty) {
        skipTransition = false;
      } else {
        skipTransition = true;
        _widgets.clear();
        _janitor.clear();
      }
    } else {
      skipTransition = false;
    }

    // * ⇑OEM check
    if (configData.shiftOEM &&
        _lastPressed.endsWith("SHIFT") &&
        rawKeyData.hasSymbol &&
        _down.length == 1) {
      _removeWithAnimation(_lastPressed);
      onlySymbol = true;
    } else {
      onlySymbol = false;
    }

    // * register keypress
    _lastPressed = vkName;
    _down.add(vkName);
    _janitor[vkName] = GlobalKey<AnimatedkeyvizState>();
    _widgets[vkName] = rawKeyData.toWidget(
      id: id,
      key: _janitor[vkName],
      onlySymbol: onlySymbol,
      skipTransition: skipTransition,
    );

    notifyListeners();

    if (configData.animation != AnimationType.none) {
      // wait for the backdrop/container to expand
      await Future.delayed(
        configData.transitionDuration,
        () =>
            skipTransition ? null : _janitor[vkName]?.currentState?.animateIn(),
      );
    }
  }

  Future<void> _removeWithAnimation(String vkName) async {
    _down.remove(vkName);

    // ? key slide/grow out animation
    _janitor[vkName]?.currentState?.animateOut();

    // ? wait for above animation out to finish
    await Future.delayed(configData.transitionDuration);

    _widgets.remove(vkName);
    _janitor.remove(vkName);

    notifyListeners();
  }

  Future<void> _removeWithoutAnimation(String vkName) async {
    _down.remove(vkName);
    _widgets.remove(vkName);
    _janitor.remove(vkName);

    notifyListeners();
  }

  void remove(String vkName, int id) async {
    // can't remove means already removed
    if (!_down.remove(vkName)) return;

    final int? pressedCount = _janitor[vkName]?.currentState?.pressedCount;

    // ? key release animation
    _janitor[vkName]?.currentState?.release();
    await Future.delayed(configData.lingerDuration); // ? interval

    // ? check if pressed again
    if (pressedCount != null &&
        pressedCount != _janitor[vkName]?.currentState?.pressedCount) return;

    if (_janitor[vkName]?.currentState?.id != id) {
      return;
    }

    if (configData.animation != AnimationType.none) {
      // ? key slide/grow out animation
      _janitor[vkName]?.currentState?.animateOut();
      // ? wait for above animation out to finish
      await Future.delayed(configData.transitionDuration);
    }

    if (!_widgets.containsKey(vkName)) return;

    _widgets.remove(vkName);
    _janitor.remove(vkName);

    notifyListeners();
  }

  void clear() {
    _widgets.clear();
    _janitor.clear();
    _down.clear();
    _lastPressed = "";

    notifyListeners();
  }

  bool isHotkey(String vkName) {
    if (_down.isEmpty) {
      if (!vkName.endsWith("SHIFT") && modifiers.containsKey(vkName)) {
        return true;
      }
    } else if (modifiers.containsKey(_down[0])) {
      return true;
    }
    return false;
  }
}
