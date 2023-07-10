import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/shared.dart';

import 'color_swatches.dart';
import 'color_picker.dart';
import 'gradient_picker.dart';

class SubPanelItem extends StatelessWidget {
  const SubPanelItem({
    super.key,
    this.enabled = true,
    required this.title,
    required this.child,
  });

  final bool enabled;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Container(
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding * .5,
      ),
      child: AnimatedOpacity(
        duration: transitionDuration,
        opacity: enabled ? 1 : .25,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: context.textTheme.titleSmall),
            IgnorePointer(ignoring: !enabled, child: child),
          ],
        ),
      ),
    );
  }
}

class SubPanelItemGroup extends StatelessWidget {
  const SubPanelItemGroup({
    super.key,
    required this.items,
  });

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      // add divider except first item
      if (i != 0) {
        children.add(
          VerticalDivider(
            // thickness: 1,
            // width: defaultPadding + 1,
            color: context.colorScheme.outline,
          ),
        );
      }
      children.add(
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding * .5),
            child: items[i],
          ),
        ),
      );
    }

    return _Container(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Row(
        children: children,
      ),
    );
  }
}

class RawInputSubPanelItem extends StatefulWidget {
  const RawInputSubPanelItem({
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
  State<RawInputSubPanelItem> createState() => _RawInputSubPanelItemState();
}

class _RawInputSubPanelItemState extends State<RawInputSubPanelItem> {
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
    final textStyle = context.textTheme.labelMedium!.copyWith(
      fontWeight: FontWeight.w500,
    );
    return RawSubPanelItem(
      title: widget.title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: defaultPadding * 3,
            child: SizedBox(
              height: textStyle.fontSize!,
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
          ),
          const VerySmallRowGap(),
          Text(widget.suffix, style: context.textTheme.bodyMedium),
        ],
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

class RawColorInputSubPanelItem extends StatefulWidget {
  const RawColorInputSubPanelItem({
    super.key,
    this.label,
    this.enabled = true,
    required this.onChanged,
    required this.defaultValue,
  });

  final String? label;
  final bool enabled;
  final Color defaultValue;
  final ValueChanged<Color> onChanged;

  @override
  State<RawColorInputSubPanelItem> createState() =>
      _RawColorInputSubPanelItemState();
}

class _RawColorInputSubPanelItemState extends State<RawColorInputSubPanelItem> {
  late Color _color;
  final _focusNode = FocusNode();
  late final TextEditingController _ctrl;

  bool _showSwatches = false;
  bool _showPicker = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _color = widget.defaultValue;
    _ctrl = TextEditingController(text: _color.toHex());
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme.labelMedium!.copyWith(
      fontWeight: FontWeight.w500,
    );
    final child = Row(
      children: [
        GestureDetector(
          onTap: _toggleColorPicker,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SizedBox.square(
              dimension: defaultPadding * 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _color,
                  border: Border.all(color: context.colorScheme.outline),
                  borderRadius: BorderRadius.circular(defaultPadding * .4),
                ),
              ),
            ),
          ),
        ),
        const SmallRowGap(),
        SizedBox(
          width: defaultPadding * 5,
          child: SizedBox(
            height: textStyle.fontSize!,
            child: TextField(
              controller: _ctrl,
              focusNode: _focusNode,
              onSubmitted: _onChanged,
              onTapOutside: _onChanged,
              style: textStyle,
              decoration: const InputDecoration.collapsed(hintText: "#hexcode"),
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.bottom,
              keyboardType: TextInputType.number,
              inputFormatters: [LengthLimitingTextInputFormatter(7)],
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: _toggleColorSwatches,
          tooltip: "Swatches",
          icon: const SvgIcon.chevronDown(size: defaultPadding * .32),
        ),
      ],
    );
    return AnimatedOpacity(
      opacity: widget.enabled ? 1 : 0.25,
      duration: transitionDuration,
      child: IgnorePointer(
        ignoring: !widget.enabled,
        child: child,
      ),
    );
  }

  _onChanged([_]) {
    if (!_focusNode.hasPrimaryFocus) return;

    if (_ctrl.text.length >= 6) {
      try {
        final color = HexColor.fromHex(_ctrl.text);
        if (color != _color) {
          setState(() => _color = color);
          widget.onChanged(_color);
        }
      } on FormatException {
        // invalid hex code
        debugPrint("Invalid hex code: ${_ctrl.text}");
      }
    }

    _ctrl.text = _color.toHex();
    _focusNode.unfocus();
  }

  _showColorSwatches() {
    final overlay = Overlay.of(context);

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _showSwatches = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + (defaultPadding),
        child: ColorSwatches(
          onSelected: _onSelected,
          show: _showSwatches,
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  Future _removeColorSwatches() async {
    _showSwatches = false;
    _overlayEntry?.markNeedsBuild();
    await Future.delayed(transitionDuration);

    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  _toggleColorSwatches() async {
    if (_overlayEntry == null) {
      _showColorSwatches();
    } else if (_showPicker) {
      await _removeColorPicker();
      _showColorSwatches();
    } else {
      _removeColorSwatches();
    }
  }

  _showColorPicker() {
    final overlay = Overlay.of(context);

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _showPicker = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - defaultPadding,
        top: offset.dy - (defaultPadding * .5),
        child: Material(
          type: MaterialType.transparency,
          child: ColorPicker(
            show: _showPicker,
            title: widget.label,
            initialColor: _color,
            onClose: _removeColorPicker,
            onChanged: _onPickerChanged,
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  Future _removeColorPicker() async {
    // update preview
    setState(() {});
    // update hex
    _ctrl.text = _color.toHex();

    _showPicker = false;
    _overlayEntry?.markNeedsBuild();
    await Future.delayed(transitionDuration);

    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  _onPickerChanged(Color color) {
    _color = color;
    widget.onChanged(color);
  }

  _toggleColorPicker() async {
    if (_overlayEntry == null) {
      _showColorPicker();
    } else if (_showSwatches) {
      await _removeColorSwatches();
      _showColorPicker();
    } else {
      _removeColorPicker();
    }
  }

  _onSelected(Color color) {
    setState(() => _color = color);

    _ctrl.text = _color.toHex();
    widget.onChanged(_color);
    // remove overlay
    _removeColorSwatches();
  }

  @override
  void dispose() {
    if (_overlayEntry != null) _overlayEntry?.remove();

    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class RawGradientInputSubPanelItem extends StatefulWidget {
  const RawGradientInputSubPanelItem({
    super.key,
    this.title,
    this.initialColor1,
    this.initialColor2,
    required this.onColor1Changed,
    required this.onColor2Changed,
  });

  final String? title;
  final Color? initialColor1;
  final Color? initialColor2;
  final ValueChanged<Color> onColor1Changed;
  final ValueChanged<Color> onColor2Changed;

  @override
  State<RawGradientInputSubPanelItem> createState() =>
      _RawGradientInputSubPanelItemState();
}

class _RawGradientInputSubPanelItemState
    extends State<RawGradientInputSubPanelItem> {
  late Color _color1;
  late Color _color2;

  bool _showPicker = false;

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _color1 = widget.initialColor1 ?? Colors.purple;
    _color2 = widget.initialColor2 ?? Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    return RawSubPanelItem(
      title: widget.title,
      child: GestureDetector(
        onTap: _togglePicker,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: SizedBox.square(
            dimension: defaultPadding * 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: context.colorScheme.outline),
                gradient: LinearGradient(
                  colors: [_color1, _color2],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(defaultPadding * .5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _togglePicker() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  _showOverlay() {
    final overlay = Overlay.of(context);

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _showPicker = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - defaultPadding,
        top: offset.dy - (defaultPadding * .5),
        child: Material(
          type: MaterialType.transparency,
          child: GradientPicker(
            show: _showPicker,
            title: widget.title,
            initialColor1: widget.initialColor1,
            initialColor2: widget.initialColor2,
            onClose: _removeOverlay,
            onColor1Changed: _onColor1Changed,
            onColor2Changed: _onColor2Changed,
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  _onColor1Changed(Color color) {
    _color1 = color;
    widget.onColor1Changed(color);
  }

  _onColor2Changed(Color color) {
    _color2 = color;
    widget.onColor2Changed(color);
  }

  _removeOverlay() async {
    // reflect color changes
    setState(() {});

    _showPicker = false;
    _overlayEntry?.markNeedsBuild();

    await Future.delayed(transitionDuration);

    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    if (_overlayEntry != null) _removeOverlay();
    super.dispose();
  }
}

class RawSubPanelItem extends StatelessWidget {
  const RawSubPanelItem({
    super.key,
    this.title,
    this.leading,
    required this.child,
  });

  final String? title;
  final Widget? leading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final titleGiven = title != null;
    final leadingGiven = leading != null;

    return Row(
      mainAxisAlignment: titleGiven || leadingGiven
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.start,
      children: [
        if (titleGiven) Text(title!, style: context.textTheme.titleSmall),
        if (!titleGiven && leadingGiven) leading!,
        child,
      ],
    );
  }
}

class _Container extends StatelessWidget {
  const _Container({
    required this.child,
    this.padding,
  });

  final EdgeInsets? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: defaultPadding * 3,
      padding: padding,
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        border: Border.all(color: context.colorScheme.outline),
        borderRadius: defaultBorderRadius,
      ),
      // constraints: const BoxConstraints(minHeight: defaultPadding * 3),
      child: child,
    );
  }
}
