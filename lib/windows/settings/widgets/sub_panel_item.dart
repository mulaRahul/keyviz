import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/shared.dart';

class SubPanelItem extends StatelessWidget {
  const SubPanelItem({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Container(
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding * .5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title, style: context.textTheme.titleSmall), child],
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

// TODO: add ability to increase/decrease number with up/down arrows
class _RawInputSubPanelItemState extends State<RawInputSubPanelItem> {
  final _focusNode = FocusNode();
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.defaultValue.toString());
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
    required this.defaultValue,
    required this.onChanged,
    this.enabled = true,
  });

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

  bool _showOverlay = false;
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
        GestureDetector(
          onTap: _toggleColorPicker,
          child: const SvgIcon.chevronDown(size: defaultPadding * .4),
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
    if (_ctrl.text.length >= 6) {
      try {
        setState(() => _color = HexColor.fromHex(_ctrl.text));
      } on FormatException {
        // invalid hex code
        debugPrint("Invalid hex code: ${_ctrl.text}");
      }
    }

    _ctrl.text = _color.toHex();
    _focusNode.unfocus();
  }

  _showColorPicker() {
    final overlay = Overlay.of(context);

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _showOverlay = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + (defaultPadding),
        child: _ColorSelector(
          onSelected: _onSelected,
          show: _showOverlay,
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  _removeColorPicker() async {
    _showOverlay = false;
    _overlayEntry?.markNeedsBuild();
    await Future.delayed(transitionDuration);

    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  _toggleColorPicker() {
    if (_overlayEntry == null) {
      _showColorPicker();
    } else {
      _removeColorPicker();
    }
  }

  _onSelected(Color color) {
    setState(() => _color = color);
    _ctrl.text = _color.toHex();

    // remove overlay
    _removeColorPicker();
  }

  @override
  void dispose() {
    if (_overlayEntry != null) _overlayEntry?.remove();

    _ctrl.dispose();
    _focusNode.dispose();
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

class _ColorSelector extends StatefulWidget {
  const _ColorSelector({required this.onSelected, required this.show});

  final void Function(Color color) onSelected;
  final bool show;

  @override
  State<_ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<_ColorSelector> {
  double get _target => widget.show ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: defaultPadding * 16.65,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: defaultBorderRadius,
        border: Border.all(color: context.colorScheme.outline),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, defaultPadding * 0.5),
            color: Colors.black12,
            blurRadius: defaultPadding * 2,
          )
        ],
      ),
      child: Wrap(
        spacing: defaultPadding * .5,
        runSpacing: defaultPadding * .5,
        children: [
          for (final color in Colors.primaries)
            GestureDetector(
              onTap: () => widget.onSelected(color),
              child: SizedBox.square(
                dimension: defaultPadding * 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(defaultPadding * .5),
                  ),
                ),
              ),
            ),
        ],
      ),
    )
        .animate(target: _target)
        .effect(
          duration: transitionDuration,
          curve: Curves.easeInOutCubicEmphasized,
        )
        .scaleXY(begin: .6, end: 1)
        .fade();
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
