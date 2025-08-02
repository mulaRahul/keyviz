import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyviz/config/config.dart';

class XNumberInput extends StatefulWidget {
  const XNumberInput({
    super.key,
    required this.title,
    required this.suffix,
    this.defaultValue = 0,
    required this.onChanged,
  });

  final String title;
  final String suffix;
  final int defaultValue;
  final void Function(int value) onChanged;

  @override
  State<XNumberInput> createState() => _XNumberInputState();
}

class _XNumberInputState extends State<XNumberInput> {
  late final FocusNode _focusNode;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.defaultValue.toString());
    _focusNode = FocusNode(onKeyEvent: _onKeyEvent);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme.labelSmall!.copyWith(
      fontWeight: FontWeight.w500,
    );
    return Container(
      width: defaultPadding * 5,
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(defaultPadding * .6),
        border: Border.all(color: context.colorScheme.outline),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding * .5,
        vertical: defaultPadding * .4,
      ),
      child: SizedBox(
        // height: textStyle.fontSize! * 2,
        child: TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          onSubmitted: _onChanged,
          onTapOutside: _onChanged,
          style: textStyle,
          textAlign: TextAlign.end,
          decoration: const InputDecoration.collapsed(hintText: "font"),
          textAlignVertical: TextAlignVertical.top,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ),
    );
  }

  _onChanged([_]) {
    if (_ctrl.text.isEmpty) {
      _ctrl.text = widget.defaultValue.toString();
    } else {
      final n = int.tryParse(_ctrl.text);
      if (n != null) {
        widget.onChanged(n);
      }
    }
    _focusNode.unfocus();
  }

  KeyEventResult _onKeyEvent(_, KeyEvent event) {
    if (["Arrow Up", "Arrow Down"].contains(event.logicalKey.keyLabel) &&
        event is KeyDownEvent) {
      try {
        // input value
        final n = int.parse(_ctrl.text);
        // increase
        if (event.logicalKey.keyLabel == "Arrow Up") {
          _ctrl.text = "${n + 1}";
          // decrease
        } else if (event.logicalKey.keyLabel == "Arrow Down" && n > 0) {
          _ctrl.text = "${n - 1}";
        }
      } on FormatException {
        // catch it
      }
      // event handled
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _ctrl.dispose();
    super.dispose();
  }
}
