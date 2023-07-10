import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/domain/services/key_maps.dart';

class HotkeyInput extends StatefulWidget {
  const HotkeyInput({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  final List<int>? initialValue;
  final ValueChanged<List<int>> onChanged;

  @override
  State<HotkeyInput> createState() => _HotkeyInputState();
}

class _HotkeyInputState extends State<HotkeyInput> {
  bool _focused = false;
  bool _hovered = false;
  late final FocusNode _focusNode;

  bool _recording = false;
  late final List<int> _ids;

  @override
  void initState() {
    super.initState();
    _ids = widget.initialValue ?? const [];
    _focusNode = FocusNode(onKeyEvent: _onKeyEvent);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = context.isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.background;

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
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding * .5,
            vertical: defaultPadding * .4,
          ),
          decoration: BoxDecoration(
            color: _hovered ? bgColor : bgColor.withOpacity(.5),
            border: Border.all(
              width: _focused ? 2 : 1,
              color: _focused
                  ? context.colorScheme.secondary
                  : context.colorScheme.outline,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            borderRadius: BorderRadius.circular(defaultPadding * .5),
          ),
          child: Row(
            children: [for (final id in _ids) _KeyCap(id)],
          ),
        ),
      ),
    );
  }

  _onTap() {
    _focusNode.requestFocus();
  }

  KeyEventResult _onKeyEvent(_, KeyEvent event) {
    if (event is KeyDownEvent) {
      // new shortcut
      if (!_recording && _ids.isNotEmpty) {
        _ids.clear();
        _recording = true;
      }
      // record key stroke
      setState(() => _ids.add(event.logicalKey.keyId));

      return KeyEventResult.handled;
    } else if (event is KeyUpEvent) {
      _recording = false;
      widget.onChanged(_ids);
      _focusNode.unfocus();
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: defaultPadding * 1.5,
      margin: const EdgeInsets.only(
        right: defaultPadding * .5,
        bottom: defaultPadding * .2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding * .5),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(defaultPadding * .4),
        border: Border.all(color: Colors.black),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, defaultPadding * .2),
          )
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _label.capitalize(),
        style: TextStyle(
          color: context.colorScheme.secondary,
          fontSize: defaultPadding * .75,
        ),
      ),
    );
  }

  String get _label {
    return keymaps[id]?.label ??
        LogicalKeyboardKey.findKeyByKeyId(id)?.keyLabel ??
        "$id";
  }
}
