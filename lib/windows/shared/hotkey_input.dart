import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';

class HotkeyInput extends StatefulWidget {
  const HotkeyInput({super.key, this.fontSize = defaultPadding});

  final double fontSize;

  @override
  State<HotkeyInput> createState() => HotkeyInputState();
}

class HotkeyInputState extends State<HotkeyInput> {
  bool _focused = false;
  bool _hovered = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(onKeyEvent: _onKeyEvent);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        child: AnimatedContainer(
          duration: transitionDuration,
          curve: Curves.easeOutCubic,
          height: defaultPadding * 3,
          decoration: BoxDecoration(
            color: _hovered
                ? context.colorScheme.onBackground
                : context.colorScheme.background,
            border: Border.all(
              width: _focused ? 2 : 1,
              color: _focused
                  ? context.colorScheme.primaryContainer
                  : context.colorScheme.onBackground,
            ),
            borderRadius: BorderRadius.circular(defaultPadding * .5),
          ),
        ),
      ),
    );
  }

  _onTap() {
    _focusNode.requestFocus();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    debugPrint(event.toString());
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
