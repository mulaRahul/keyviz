import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyviz/data/config.dart';

import '../data/properties.dart';

class Flatkeyviz extends StatefulWidget {
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

  const Flatkeyviz({
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
  State<Flatkeyviz> createState() => FlatkeyvizState();
}

class FlatkeyvizState extends State<Flatkeyviz> {
  bool pressed = true;
  late final double borderWidth;
  late final BorderRadius borderRadius;
  late final Color darkBaseColor;
  late final Color darkerBaseColor;
  late final BoxConstraints constraints;
  late final Container bottomLayer;
  late final Container topLayer;

  void press() => setState(() => pressed = true);
  void release() => setState(() => pressed = false);

  @override
  void initState() {
    super.initState();
    // ? properties
    borderWidth = widget.fontSize / 15;
    final double gValue = grayscaleValue(widget.baseColor) / 255;
    borderRadius = BorderRadius.circular(widget.fontSize / 3);
    constraints = BoxConstraints(minWidth: widget.fontSize * 2.5);

    // ? colors
    darkBaseColor = darken(widget.baseColor, gValue.clamp(0.0, .12));
    darkerBaseColor = darken(widget.baseColor, gValue.clamp(0.1, .36));

    // ? layers
    bottomLayer = Container(
      height: widget.fontSize * 2.5,
      width: widget.width,
      constraints: constraints,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkerBaseColor, darkBaseColor],
          stops: const [.84, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: darkerBaseColor,
          width: borderWidth / 1.5,
        ),
        borderRadius: borderRadius,
      ),
    );

    topLayer = Container(
      padding: EdgeInsets.all(widget.fontSize / 2.8),
      alignment: widget.textAlignment,
      width: widget.width,
      height: widget.fontSize * 2.5,
      constraints: constraints,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.baseColor, darkBaseColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: widget.baseColor, width: borderWidth),
        borderRadius: borderRadius,
      ),
      child: getText(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        bottomLayer,
        AnimatedPadding(
          curve: Curves.easeOutCirc,
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.only(
              bottom: pressed ? borderWidth : widget.fontSize / 4),
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

  SizedBox icon() {
    return SizedBox(
      height: widget.fontSize / 1.5,
      width: widget.fontSize / 1.5,
      child: SvgPicture.asset(
        widget.iconPath!,
        color: widget.fontColor,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget text(String text) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Text(
        text,
        style: TextStyle(
          height: 1,
          color: widget.fontColor,
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
          width: widget.fontSize / 2,
          height: widget.fontSize / 2,
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
            maxLines: 1,
            style: TextStyle(
              height: 1,
              color: widget.fontColor,
              fontSize: widget.fontSize / 1.8,
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
            fontSize: widget.fontSize / 1.6,
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            widget.keyName,
            style: TextStyle(
              height: 1,
              color: widget.fontColor,
              fontSize: widget.fontSize / 1.4,
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
            fontSize: widget.fontSize / 1.6,
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            widget.symbol!,
            style: TextStyle(
              height: 1,
              color: widget.fontColor,
              fontSize: widget.fontSize / 1.4,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}

class FlatStyleKey extends StatelessWidget {
  final double width;
  final String? symbol;
  final String keyName;
  final double fontSize;
  final Color baseColor;
  final Color fontColor;
  final String? iconPath;
  final Alignment textAlignment;

  const FlatStyleKey({
    Key? key,
    this.symbol,
    this.iconPath,
    this.fontSize = 32.0,
    required this.width,
    required this.keyName,
    required this.baseColor,
    required this.fontColor,
    this.textAlignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ? properties
    final double borderWidth = fontSize / 15;
    final double gValue = grayscaleValue(baseColor) / 255;
    final BorderRadius borderRadius = BorderRadius.circular(fontSize / 3);
    final BoxConstraints constraints = BoxConstraints(minWidth: fontSize * 2.5);

    // ? colors
    final Color darkBaseColor = darken(baseColor, gValue.clamp(0.0, .12));
    final Color darkerBaseColor = darken(baseColor, gValue.clamp(0.1, .36));

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AnimatedContainer(
          duration: configData.transitionDuration,
          curve: Curves.fastOutSlowIn,
          height: fontSize * 2.5,
          width: width,
          constraints: constraints,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [darkerBaseColor, darkBaseColor],
              stops: const [.84, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: darkerBaseColor,
              width: borderWidth / 1.5,
            ),
            borderRadius: borderRadius,
          ),
        ),
        AnimatedContainer(
          duration: configData.transitionDuration,
          curve: Curves.fastOutSlowIn,
          padding: EdgeInsets.all(fontSize / 2.8),
          margin: EdgeInsets.only(bottom: fontSize / 4),
          alignment: textAlignment,
          width: width,
          height: fontSize * 2.5,
          constraints: constraints,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [baseColor, darkBaseColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: baseColor, width: borderWidth),
            borderRadius: borderRadius,
          ),
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
    return text(keyName);
  }

  Widget text(String text) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Text(
        text,
        style: TextStyle(
          height: 1,
          color: fontColor,
          fontSize: fontSize,
        ),
      ),
    );
  }

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
          width: fontSize / 2,
          height: fontSize / 2,
          child: SvgPicture.asset(
            iconPath!,
            color: fontColor,
            fit: BoxFit.contain,
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            keyName,
            maxLines: 1,
            style: TextStyle(
              height: 1,
              color: fontColor,
              fontSize: fontSize / 1.8,
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
            fontSize: fontSize / 1.6,
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            keyName,
            style: TextStyle(
              height: 1,
              color: fontColor,
              fontSize: fontSize / 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
