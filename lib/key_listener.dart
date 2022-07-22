import 'package:flutter/material.dart' hide KeyEvent;
import 'package:flutter/services.dart' hide KeyEvent;
import 'package:keyboard_event/keyboard_event.dart';
import 'package:keyviz/providers/keyboard_event.dart';
import 'package:provider/provider.dart';

class KeyboardEventListener extends StatefulWidget {
  final Widget child;

  const KeyboardEventListener({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<KeyboardEventListener> createState() => KeyboardEventListenerState();
}

class KeyboardEventListenerState extends State<KeyboardEventListener> {
  final List<String> _err = [];

  late final KeyboardEvent _keyboardEvent;
  late KeyboardEventProvider _keyEventProvider;
  final Map<String, int> _ids = {};
  late bool _listening;

  bool get listening => _listening;

  @override
  void initState() {
    super.initState();
    _initPlatformState();

    _keyboardEvent = KeyboardEvent();
    _keyboardEvent.startListening(_handleKeyEvent);

    _listening = true;
  }

  @override
  void didChangeDependencies() {
    _keyEventProvider = Provider.of<KeyboardEventProvider>(context);
    super.didChangeDependencies();
  }

  void toggleListener() {
    if (_listening) {
      _keyboardEvent.cancelListening();
      _listening = false;
    } else {
      _keyboardEvent.startListening(_handleKeyEvent);
      _listening = true;
    }
  }

  Future<void> _initPlatformState() async {
    List<String> err = [];
    try {
      await KeyboardEvent.init();
    } on PlatformException {
      err.add('Failed to get virtual-key map.');
    }
    if (!mounted) return;

    setState(() {
      if (err.isNotEmpty) _err.addAll(err);
    });
  }

  void _handleKeyEvent(KeyEvent keyEvent) async {
    final String vkName = keyEvent.vkName.toString();
    if (keyEvent.isKeyDown) {
      // ? key is pressed, add it to the list
      if (_keyEventProvider.has(vkName)) return;
      _ids[vkName] = keyEvent.hashCode;
      _keyEventProvider.add(vkName, keyEvent.hashCode);
    } else if (keyEvent.isKeyUP) {
      // ? key is released, remove it from the list
      _keyEventProvider.remove(
          keyEvent.vkName.toString(), _ids.remove(vkName) ?? 0);
    }
  }

  void refresh() => _keyEventProvider.clear();

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _keyboardEvent.cancelListening();
    debugPrint(_err.toString());
    super.dispose();
  }
}
