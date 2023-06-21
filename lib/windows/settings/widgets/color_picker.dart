import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/spacing.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({super.key, this.initialColor});

  final Color? initialColor;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late HSVColor _hsvColor;

  late final TextEditingController _hexCtrl;

  late final TextEditingController _hueCtrl;
  late final TextEditingController _saturationCtrl;
  late final TextEditingController _brightnessCtrl;

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
  }

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black12,
            blurRadius: defaultPadding * 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(defaultPadding * .25),
            decoration: _decor,
            child: Row(
              children: [
                SizedBox.square(
                  dimension: defaultPadding * 2,
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
                    controller: _hexCtrl,
                    decoration: const InputDecoration.collapsed(
                      hintText: "#hexcode",
                    ),
                    style: context.textTheme.labelMedium,
                    onSubmitted: _onHexChanged,
                    onTapOutside: _onHexChanged,
                  ),
                ),
              ],
            ),
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
            },
          ),
          const VerySmallColumnGap(),
          _HuePicker(
            hsvColor: _hsvColor,
            onChanged: (double percent) {
              setState(() => _hsvColor = _hsvColor.withHue(360 * percent));
              _updateHexInput();
              _updateHueInput(percent);
            },
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
                    controller: _hueCtrl,
                    inputFormatters: [LengthLimitingTextInputFormatter(3)],
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration.collapsed(hintText: "H"),
                    onTapOutside: _onHueChanged,
                    onSubmitted: _onHueChanged,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: TextField(
                    controller: _saturationCtrl,
                    textAlign: TextAlign.center,
                    inputFormatters: [LengthLimitingTextInputFormatter(3)],
                    decoration: const InputDecoration.collapsed(hintText: "S"),
                    onTapOutside: _onSaturationChanged,
                    onSubmitted: _onSaturationChanged,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: TextField(
                    controller: _brightnessCtrl,
                    textAlign: TextAlign.center,
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
    );
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
    if (_hexCtrl.text.length >= 6) {
      try {
        setState(
          () => _hsvColor = HSVColor.fromColor(
            HexColor.fromHex(_hexCtrl.text),
          ),
        );
      } on FormatException {
        // invalid hex code
        debugPrint("Invalid hex code: ${_hexCtrl.text}");
      }
    }

    _updateHexInput();

    // update hsl input fields
    _updateHueInput();
    _updateSaturationAndBrightnessInputs();
  }

  _onHueChanged([_]) {
    final hue = int.tryParse(_hueCtrl.text);

    if (hue != null) {
      setState(
        () => _hsvColor = _hsvColor.withHue(
          (hue / 255) * 360,
        ),
      );
      _updateHexInput();
    } else {
      _updateHueInput();
    }
  }

  _onSaturationChanged([_]) {
    final saturation = int.tryParse(_saturationCtrl.text);

    if (saturation != null) {
      setState(
        () => _hsvColor = _hsvColor.withSaturation(saturation / 100),
      );
      _updateHexInput();
    } else {
      _saturationCtrl.text = (_hsvColor.saturation * 100).toInt().toString();
    }
  }

  _onBrightnessChanged([_]) {
    final brightness = int.tryParse(_brightnessCtrl.text);

    if (brightness != null) {
      setState(
        () => _hsvColor = _hsvColor.withValue(brightness / 100),
      );
      _updateHexInput();
    } else {
      _brightnessCtrl.text = (_hsvColor.value * 100).toInt().toString();
    }
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
