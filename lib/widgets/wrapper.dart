import 'package:flutter/material.dart';

import '../animations/grow.dart';
import '../animations/slide.dart';
import '../data/config.dart';
import '../animations/fade.dart';
import '../data/properties.dart';
import 'iso_keycap.dart';
import 'solid_keycap.dart';

class Animatedkeyviz extends StatefulWidget {
  final int id;
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
  final bool skipTransition;
  final Alignment textAlignment;

  const Animatedkeyviz({
    Key? key,
    this.symbol,
    this.iconPath,
    this.fontSize = 32.0,
    this.onlyIcon = false,
    this.isNumpad = false,
    this.onlySymbol = false,
    this.skipTransition = false,
    this.textAlignment = Alignment.center,
    required this.id,
    required this.width,
    required this.keyName,
    required this.baseColor,
    required this.fontColor,
  }) : super(key: key);

  @override
  State<Animatedkeyviz> createState() => AnimatedkeyvizState();
}

class AnimatedkeyvizState extends State<Animatedkeyviz> {
  int _pressedCount = 1; // ? `cuz keyviz comes pressed
  late int id;
  GlobalKey<dynamic>? containerKey;
  late final GlobalKey<dynamic> keyvizKey;
  late final Widget keyvizWidget;
  late final Widget animatedkeyvizWidget;

  @override
  void initState() {
    super.initState();

    id = widget.id;

    switch (configData.style) {
      case KeycapStyle.solid:
        keyvizKey = GlobalKey<SolidkeyvizState>();
        keyvizWidget = Solidkeyviz(
          key: keyvizKey,
          iconPath: widget.iconPath,
          symbol: widget.symbol,
          width: widget.width,
          onlyIcon: widget.onlyIcon,
          isNumpad: widget.isNumpad,
          keyName: widget.keyName,
          onlySymbol: widget.onlySymbol,
          fontSize: widget.fontSize,
          baseColor: widget.baseColor,
          fontColor: widget.fontColor,
          textAlignment: widget.textAlignment,
        );
        break;

      case KeycapStyle.isometric:
        keyvizKey = GlobalKey<IsokeyvizState>();
        keyvizWidget = Isokeyviz(
          key: keyvizKey,
          iconPath: widget.iconPath,
          symbol: widget.symbol,
          width: widget.width,
          onlyIcon: widget.onlyIcon,
          isNumpad: widget.isNumpad,
          keyName: widget.keyName,
          onlySymbol: widget.onlySymbol,
          fontSize: widget.fontSize,
          baseColor: widget.baseColor,
          fontColor: widget.fontColor,
          textAlignment: widget.textAlignment,
        );
        break;
    }

    switch (configData.animation) {
      case AnimationType.none:
        break;

      case AnimationType.slide:
        containerKey = GlobalKey<SlideUpAnimationState>();
        animatedkeyvizWidget = SlideUpAnimation(
          key: containerKey,
          skipTransition: widget.skipTransition,
          child: keyvizWidget,
        );
        break;
      case AnimationType.fade:
        containerKey = GlobalKey<FadeAnimationState>();
        animatedkeyvizWidget = FadeAnimation(
          key: containerKey,
          skipTransition: widget.skipTransition,
          child: keyvizWidget,
        );
        break;

      case AnimationType.grow:
        containerKey = GlobalKey<GrowAnimationState>();
        animatedkeyvizWidget = GrowAnimation(
          key: containerKey,
          skipTransition: widget.skipTransition,
          child: keyvizWidget,
        );
        break;
    }
  }

  int get pressedCount => _pressedCount;

  void animateIn() => containerKey?.currentState?.animateIn();
  void animateOut() => containerKey?.currentState?.animateOut();

  void press() {
    keyvizKey.currentState?.press();
    _pressedCount++;
  }

  void release() => keyvizKey.currentState?.release();

  @override
  Widget build(BuildContext context) =>
      configData.animation == AnimationType.none
          ? keyvizWidget
          : animatedkeyvizWidget;
}
