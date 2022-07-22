import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyviz/data/config.dart';

import '../data/properties.dart';

class Isokeyviz extends StatefulWidget {
  final double width;
  final bool onlyIcon;
  final bool isNumpad;
  final String? symbol;
  final String keyName;
  final bool onlySymbol;
  final double fontSize;
  final Color baseColor;
  final Color fontColor;
  final String? iconPath;
  final Alignment textAlignment;

  const Isokeyviz({
    Key? key,
    this.symbol,
    this.iconPath,
    this.fontSize = 32.0,
    this.onlyIcon = false,
    this.isNumpad = false,
    this.onlySymbol = false,
    this.textAlignment = Alignment.center,
    required this.width,
    required this.keyName,
    required this.baseColor,
    required this.fontColor,
  }) : super(key: key);

  @override
  State<Isokeyviz> createState() => IsokeyvizState();
}

class IsokeyvizState extends State<Isokeyviz> {
  bool pressed = true;
  late final BorderRadius borderRadius;
  late final Color darkBaseColor;
  late final Color darkerBaseColor;
  late final Container bottomLayer;
  late final Container topLayer;

  @override
  void initState() {
    super.initState();

    // ? properties
    borderRadius = BorderRadius.circular(widget.fontSize / 2);
    final double gValue = grayscaleValue(widget.baseColor) / 255;
    // ? colors
    darkBaseColor = darken(widget.baseColor, gValue.clamp(0.0, .1));
    darkerBaseColor = darken(widget.baseColor, gValue.clamp(0.1, .32));
    // ? layers
    bottomLayer = Container(
      width: widget.width * 1.05,
      height: widget.fontSize * 2.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [widget.baseColor, darkerBaseColor],
        ),
        border: Border.all(color: darkerBaseColor, width: widget.fontSize / 15),
        borderRadius: borderRadius,
      ),
    );
    topLayer = Container(
      padding: EdgeInsets.all(widget.fontSize / 3),
      width: widget.width - (widget.fontSize / 2),
      height: widget.fontSize * 2,
      alignment: widget.textAlignment,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [darkBaseColor, widget.baseColor],
          ),
          borderRadius: borderRadius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: widget.baseColor,
              offset: Offset(0, widget.fontSize / 22),
            ),
          ]),
      child: getText(),
    );
  }

  void press() => setState(() => pressed = true);
  void release() => setState(() => pressed = false);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        bottomLayer,
        AnimatedPadding(
          curve: Curves.easeOutCirc,
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(top: widget.fontSize / (pressed ? 6 : 20)),
          child: topLayer,
        ),
      ],
    );
  }

  Widget getText() {
    if (widget.iconPath != null) {
      return widget.onlyIcon ? icon() : textWithIcon();
    } else if (widget.isNumpad) {
      return textNumpad();
    } else if (widget.symbol != null) {
      return widget.onlySymbol ? text(widget.symbol!) : textWithSymbol();
    } else {
      return text(widget.keyName);
    }
  }

  Widget icon() {
    return SizedBox(
      width: widget.fontSize * .8,
      height: widget.fontSize * .8,
      child: SvgPicture.asset(
        widget.iconPath!,
        fit: BoxFit.contain,
        color: widget.fontColor,
      ),
    );
  }

  Widget text(String text) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w300,
          color: widget.fontColor,
          height: 1,
          fontSize: widget.fontSize,
        ),
      ),
    );
  }

  Widget textWithIcon() {
    late final CrossAxisAlignment axisAlignment;

    if (widget.textAlignment == Alignment.center) {
      axisAlignment = CrossAxisAlignment.center;
    } else if (widget.textAlignment == Alignment.centerLeft) {
      axisAlignment = CrossAxisAlignment.start;
    } else if (widget.textAlignment == Alignment.centerRight) {
      axisAlignment = CrossAxisAlignment.end;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: axisAlignment,
      children: [
        SizedBox(
          width: widget.fontSize / 2.25,
          height: widget.fontSize / 2.25,
          child: SvgPicture.asset(
            // for some reason height isn't used
            widget.iconPath!,
            color: widget.fontColor,
            fit: BoxFit.contain,
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            widget.keyName,
            style: TextStyle(
              height: 1,
              color: widget.fontColor,
              fontSize: widget.fontSize / 2,
            ),
          ),
        )
      ],
    );
  }

  Widget textWithSymbol() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.symbol!,
          style: TextStyle(
            height: 1,
            color: widget.fontColor,
            fontSize: widget.fontSize / (_isSymbolTall() ? 2 : 1.75),
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            widget.keyName,
            style: TextStyle(
              height: 1,
              color: widget.fontColor,
              fontSize: widget.fontSize / (_isTextTall() ? 2 : 1.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget textNumpad() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.keyName,
          style: TextStyle(
            height: 1,
            color: widget.fontColor,
            fontSize: widget.fontSize / 1.5,
            fontWeight: FontWeight.w300,
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            widget.symbol!,
            style: TextStyle(
              height: 1,
              color: widget.fontColor,
              fontSize: widget.fontSize / 2,
            ),
          ),
        ),
      ],
    );
  }

  bool _isSymbolTall() {
    return "(){}|".contains(widget.symbol!);
  }

  bool _isTextTall() {
    return "[]\\/".contains(widget.keyName);
  }
}

class IsoStyleKey extends StatelessWidget {
  final double width;
  final String? symbol;
  final String keyName;
  final double fontSize;
  final Color baseColor;
  final Color fontColor;
  final String? iconPath;
  final Alignment textAlignment;

  const IsoStyleKey({
    Key? key,
    required this.width,
    this.symbol,
    required this.keyName,
    required this.fontSize,
    required this.baseColor,
    required this.fontColor,
    this.iconPath,
    required this.textAlignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ? properties
    final BorderRadius borderRadius = BorderRadius.circular(fontSize / 2);
    final double gValue = grayscaleValue(baseColor) / 255;
    // ? colors
    final Color darkBaseColor = darken(baseColor, gValue.clamp(0.0, .1));
    final Color darkerBaseColor = darken(baseColor, gValue.clamp(0.1, .32));

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AnimatedContainer(
          duration: configData.transitionDuration,
          curve: Curves.fastOutSlowIn,
          width: width * 1.05,
          height: fontSize * 2.6,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, darkerBaseColor],
            ),
            border: Border.all(color: darkerBaseColor, width: fontSize / 15),
            borderRadius: borderRadius,
          ),
        ),
        AnimatedContainer(
          duration: configData.transitionDuration,
          curve: Curves.fastOutSlowIn,
          padding: EdgeInsets.all(fontSize / 3),
          margin: EdgeInsets.only(top: fontSize / 20),
          width: width - (fontSize / 2),
          height: fontSize * 2,
          alignment: textAlignment,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [darkBaseColor, baseColor],
              ),
              borderRadius: borderRadius,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: baseColor,
                  offset: Offset(0, fontSize / 22),
                ),
              ]),
          child: getText(),
        ),
      ],
    );
  }

  Widget getText() {
    if (iconPath != null) {
      return textWithIcon();
    } else if (symbol != null) {
      return textWithSymbol();
    }
    return text();
  }

  Widget text() => FittedBox(
        fit: BoxFit.contain,
        child: Text(
          keyName,
          style: TextStyle(
            fontWeight: FontWeight.w300,
            color: fontColor,
            height: 1,
            fontSize: fontSize,
          ),
        ),
      );

  Widget textWithIcon() {
    late final CrossAxisAlignment axisAlignment;

    if (textAlignment == Alignment.center) {
      axisAlignment = CrossAxisAlignment.center;
    } else if (textAlignment == Alignment.centerLeft) {
      axisAlignment = CrossAxisAlignment.start;
    } else if (textAlignment == Alignment.centerRight) {
      axisAlignment = CrossAxisAlignment.end;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: axisAlignment,
      children: [
        SizedBox(
          width: fontSize / 2.25,
          height: fontSize / 2.25,
          child: SvgPicture.asset(
            // for some reason height isn't used
            iconPath!,
            color: fontColor,
            fit: BoxFit.contain,
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            keyName,
            style: TextStyle(
              height: 1,
              color: fontColor,
              fontSize: fontSize / 2,
            ),
          ),
        )
      ],
    );
  }

  Widget textWithSymbol() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          symbol!,
          style: TextStyle(
            height: 1,
            color: fontColor,
            fontSize: fontSize / 1.75,
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            keyName,
            style: TextStyle(
              height: 1,
              color: fontColor,
              fontSize: fontSize / 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
