import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/shared.dart';

enum _ColorSpace { hue, saturation, brightness }

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    this.title,
    this.onClose,
    this.initialColor,
    required this.show,
    required this.onChanged,
  });

  final bool show;
  final String? title;
  final Color? initialColor;
  final VoidCallback? onClose;
  final ValueChanged<Color> onChanged;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late HSVColor _hsvColor;

  late final TextEditingController _hexCtrl;

  final FocusNode _hexFocusNode = FocusNode();
  late final FocusNode _hueFocusNode;
  late final TextEditingController _hueCtrl;

  late final FocusNode _saturationFocusNode;
  late final TextEditingController _saturationCtrl;

  late final FocusNode _brightnessFocusNode;
  late final TextEditingController _brightnessCtrl;

  bool _clipboardCopied = false;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor ?? Colors.purple);
    _hexCtrl = TextEditingController(text: _hsvColor.toHex());

    _hueCtrl =
        TextEditingController(text: (_huePercent * 255).floor().toString());
    _saturationCtrl = TextEditingController(
      text: (_hsvColor.saturation * 100).floor().toString(),
    );
    _brightnessCtrl = TextEditingController(
      text: (_hsvColor.value * 100).floor().toString(),
    );

    _hueFocusNode = FocusNode(
      onKeyEvent: (_, event) => _onKeyEvent(event, _hueCtrl, _ColorSpace.hue),
    );
    _saturationFocusNode = FocusNode(
      onKeyEvent: (_, event) =>
          _onKeyEvent(event, _saturationCtrl, _ColorSpace.saturation),
    );
    _brightnessFocusNode = FocusNode(
      onKeyEvent: (_, event) =>
          _onKeyEvent(event, _brightnessCtrl, _ColorSpace.brightness),
    );
  }

  double get _target => widget.show ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    final inputStyle = context.textTheme.labelSmall?.copyWith(fontSize: 14);
    return Container(
      width: 240,
      // height: 500,
      padding: const EdgeInsets.all(defaultPadding * .5),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        border: Border.all(color: context.colorScheme.outline),
        borderRadius: defaultBorderRadius,
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, defaultPadding * .5),
            color: Colors.black26,
            blurRadius: defaultPadding * 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                widget.title ?? "Color Picker",
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.tertiary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onClose,
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(defaultPadding * .25),
                ),
                icon: SvgIcon.cross(
                  color: context.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const VerySmallColumnGap(),
          _SaturationAndBrightnessPicker(
            hsvColor: _hsvColor,
            onChanged: (double saturation, double brightness) {
              setState(
                () => _hsvColor = HSVColor.fromAHSV(
                    1.0, _hsvColor.hue, saturation, brightness),
              );
              _updateHexInput();
              _updateSaturationAndBrightnessInputs();
              widget.onChanged(_hsvColor.toColor());
            },
          ),
          const VerySmallColumnGap(),
          _HuePicker(
            hsvColor: _hsvColor,
            onChanged: (double percent) {
              setState(() => _hsvColor = _hsvColor.withHue(360 * percent));
              _updateHexInput();
              _updateHueInput(percent);
              widget.onChanged(_hsvColor.toColor());
            },
          ),
          const VerySmallColumnGap(),
          Container(
            padding: const EdgeInsets.all(defaultPadding * .25),
            decoration: _decor,
            child: Row(
              children: [
                SizedBox.square(
                  dimension: defaultPadding * 1.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _hsvColor.toColor(),
                      borderRadius: BorderRadius.circular(defaultPadding * .25),
                    ),
                  ),
                ),
                const SmallRowGap(),
                Expanded(
                  child: TextField(
                    focusNode: _hexFocusNode,
                    controller: _hexCtrl,
                    decoration: const InputDecoration.collapsed(
                      hintText: "#hexcode",
                    ),
                    style: inputStyle,
                    onSubmitted: _onHexChanged,
                    onTapOutside: _onHexChanged,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _hexCtrl.text));
                    setState(() => _clipboardCopied = true);
                    Future.delayed(const Duration(seconds: 4))
                        .then((_) => _clipboardCopied = false);
                  },
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(defaultPadding * .25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultPadding * .5),
                    ),
                  ),
                  icon: SvgIcon(
                    icon: _clipboardCopied
                        ? VuesaxIcons.clipboardTick
                        : VuesaxIcons.clipboard,
                    color: context.colorScheme.tertiary,
                  ),
                  tooltip: _clipboardCopied ? "Copied" : "Copy",
                ),
              ],
            ),
          ),
          const VerySmallColumnGap(),
          Container(
            width: double.maxFinite,
            height: defaultPadding * 2,
            decoration: _decor,
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding * .5,
                  ),
                  color: context.colorScheme.secondaryContainer,
                  alignment: Alignment.center,
                  child: Text("HSL", style: context.textTheme.bodyLarge),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: TextField(
                    focusNode: _hueFocusNode,
                    controller: _hueCtrl,
                    inputFormatters: [LengthLimitingTextInputFormatter(3)],
                    textAlign: TextAlign.center,
                    style: inputStyle,
                    decoration: const InputDecoration.collapsed(hintText: "H"),
                    onTapOutside: _onHueChanged,
                    onSubmitted: _onHueChanged,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: TextField(
                    focusNode: _saturationFocusNode,
                    controller: _saturationCtrl,
                    textAlign: TextAlign.center,
                    style: inputStyle,
                    inputFormatters: [LengthLimitingTextInputFormatter(3)],
                    decoration: const InputDecoration.collapsed(hintText: "S"),
                    onTapOutside: _onSaturationChanged,
                    onSubmitted: _onSaturationChanged,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: TextField(
                    focusNode: _brightnessFocusNode,
                    controller: _brightnessCtrl,
                    textAlign: TextAlign.center,
                    style: inputStyle,
                    inputFormatters: [LengthLimitingTextInputFormatter(3)],
                    decoration: const InputDecoration.collapsed(hintText: "L"),
                    onTapOutside: _onBrightnessChanged,
                    onSubmitted: _onBrightnessChanged,
                  ),
                ),
              ],
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

  double get _huePercent {
    return _hsvColor.hue / 360;
  }

  BoxDecoration get _decor => BoxDecoration(
        border: Border.all(
          color: context.colorScheme.outline,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(defaultPadding * .5),
      );

  _onHexChanged([_]) {
    if (!_hexFocusNode.hasPrimaryFocus) return;

    if (_hexCtrl.text.length >= 6) {
      try {
        setState(
          () => _hsvColor = HSVColor.fromColor(
            HexColor.fromHex(_hexCtrl.text),
          ),
        );
        widget.onChanged(_hsvColor.toColor());
      } on FormatException {
        // invalid hex code
        debugPrint("Invalid hex code: ${_hexCtrl.text}");
      }
    }

    _updateInputs();
    _hexFocusNode.unfocus();
  }

  _onHueChanged([_]) {
    if (!_hueFocusNode.hasPrimaryFocus) return;

    final hue = int.tryParse(_hueCtrl.text);

    if (hue != null) {
      setState(
        () => _hsvColor = _hsvColor.withHue(
          (hue / 255) * 360,
        ),
      );
      _updateHexInput();
      widget.onChanged(_hsvColor.toColor());
    } else {
      _updateHueInput();
    }

    _hueFocusNode.unfocus();
  }

  _onSaturationChanged([_]) {
    if (!_saturationFocusNode.hasPrimaryFocus) return;

    final saturation = int.tryParse(_saturationCtrl.text);

    if (saturation != null) {
      setState(
        () => _hsvColor = _hsvColor.withSaturation(saturation / 100),
      );
      _updateHexInput();
      widget.onChanged(_hsvColor.toColor());
    } else {
      _saturationCtrl.text = (_hsvColor.saturation * 100).toInt().toString();
    }

    _saturationFocusNode.unfocus();
  }

  _onBrightnessChanged([_]) {
    if (!_brightnessFocusNode.hasPrimaryFocus) return;

    final brightness = int.tryParse(_brightnessCtrl.text);

    if (brightness != null) {
      setState(
        () => _hsvColor = _hsvColor.withValue(brightness / 100),
      );
      _updateHexInput();
      widget.onChanged(_hsvColor.toColor());
    } else {
      _brightnessCtrl.text = (_hsvColor.value * 100).toInt().toString();
    }

    _brightnessFocusNode.unfocus();
  }

  _updateInputs() {
    _updateHexInput();
    _updateHueInput();
    _updateSaturationAndBrightnessInputs();
  }

  _updateHexInput() {
    _hexCtrl.text = _hsvColor.toHex();
  }

  _updateHueInput([double? percent]) {
    _hueCtrl.text =
        (percent != null ? (255 * percent) : 255 * (_hsvColor.hue / 360))
            .toInt()
            .toString();
  }

  _updateSaturationAndBrightnessInputs() {
    _saturationCtrl.text = (_hsvColor.saturation * 100).toInt().toString();
    _brightnessCtrl.text = (_hsvColor.value * 100).toInt().toString();
  }

  KeyEventResult _onKeyEvent(
    KeyEvent event,
    TextEditingController ctrl,
    _ColorSpace colorSpace,
  ) {
    if (["Arrow Up", "Arrow Down"].contains(event.logicalKey.keyLabel) &&
        event is KeyDownEvent) {
      try {
        // input value
        int n = int.parse(ctrl.text);

        // increase
        if (event.logicalKey.keyLabel == "Arrow Up") {
          // max limit
          if (colorSpace == _ColorSpace.hue) {
            if (n >= 255) return KeyEventResult.ignored;
          } else {
            if (n >= 100) return KeyEventResult.ignored;
          }
          ctrl.text = "${n + 1}";
          // decrease
        } else if (event.logicalKey.keyLabel == "Arrow Down" && n > 0) {
          ctrl.text = "${n - 1}";
        }

        // update color
        setState(() {
          switch (colorSpace) {
            case _ColorSpace.hue:
              _hsvColor = _hsvColor.withHue((n / 255) * 360);
              break;

            case _ColorSpace.saturation:
              _hsvColor = _hsvColor.withSaturation(n / 100);
              break;

            case _ColorSpace.brightness:
              _hsvColor = _hsvColor.withValue(n / 100);
              break;
          }
          widget.onChanged(_hsvColor.toColor());
          _updateHexInput();
        });

        //  event handled
        return KeyEventResult.handled;
      } on FormatException {
        // catch it
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    _hueCtrl.dispose();
    _saturationCtrl.dispose();
    _brightnessCtrl.dispose();
    super.dispose();
  }
}

class _SaturationAndBrightnessPicker extends StatelessWidget {
  const _SaturationAndBrightnessPicker({
    this.size = 224,
    required this.hsvColor,
    required this.onChanged,
  });

  final double size;
  final HSVColor hsvColor;
  final void Function(double saturation, double brightness) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => _onPan(details.localPosition),
      onPanUpdate: (details) => _onPan(details.localPosition),
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: _decor(context).copyWith(
                gradient: const LinearGradient(
                  colors: [Colors.white, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            DecoratedBox(
              decoration: _decor(context).copyWith(
                gradient: LinearGradient(
                  colors: [
                    HSVColor.fromAHSV(1.0, hsvColor.hue, 0.0, 1.0).toColor(),
                    HSVColor.fromAHSV(1.0, hsvColor.hue, 1.0, 1.0).toColor(),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                backgroundBlendMode: BlendMode.modulate,
              ),
            ),
            Positioned(
              left: (size - defaultPadding) * hsvColor.saturation,
              top: (size - defaultPadding) * (1 - hsvColor.value),
              width: defaultPadding,
              height: defaultPadding,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _decor(BuildContext context) {
    return BoxDecoration(
      border: Border.all(
        color: context.colorScheme.outline,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      borderRadius: BorderRadius.circular(defaultPadding * .5),
    );
  }

  _onPan(Offset position) {
    if (position.dx >= 0 && position.dx <= size ||
        position.dy >= 0 && position.dy <= size) {
      onChanged(
        (position.dx / size).clamp(0, 1),
        (1 - (position.dy / size)).clamp(0, 1),
      );
    }
  }
}

class _HuePicker extends StatelessWidget {
  const _HuePicker({
    required this.hsvColor,
    required this.onChanged,
    this.width = 224,
  });

  final double width;
  final HSVColor hsvColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragDown: _onHorizontalDragDown,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      child: SizedBox(
        width: width,
        height: defaultPadding * 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.colorScheme.outline,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  borderRadius: BorderRadius.circular(defaultPadding * .5),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFFF0000),
                      Color(0xFFFFFF00),
                      Color(0xFF00FF00),
                      Color(0xFF00FFFF),
                      Color(0xFF0000FF),
                      Color(0xFFFF00FF),
                      Color(0xFFFF0000),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: (width - defaultPadding) * (hsvColor.hue / 360),
              width: defaultPadding,
              height: defaultPadding,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      HSVColor.fromAHSV(1.0, hsvColor.hue, 1.0, 1.0).toColor(),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onHorizontalDragUpdate(DragUpdateDetails details) {
    final dx = details.localPosition.dx;
    if (dx >= 0 && dx <= width) {
      onChanged(dx / width);
    }
  }

  _onHorizontalDragDown(DragDownDetails details) {
    final dx = details.localPosition.dx;
    if (dx >= 0 && dx <= width) {
      onChanged(dx / width);
    }
  }
}
