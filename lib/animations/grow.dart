import 'package:flutter/material.dart';

import '../data/config.dart';

class GrowAnimation extends StatefulWidget {
  final Widget child;
  final bool skipTransition;

  const GrowAnimation({
    Key? key,
    required this.child,
    this.skipTransition = false,
  }) : super(key: key);

  @override
  State<GrowAnimation> createState() => GrowAnimationState();
}

class GrowAnimationState extends State<GrowAnimation> {
  late double scale;

  @override
  void initState() {
    scale = widget.skipTransition ? 1 : 0;
    super.initState();
  }

  void animateIn() => setState(() => scale = 1);
  void animateOut() => setState(() => scale = 0);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale,
      curve: Curves.easeOutExpo,
      duration: configData.transitionDuration,
      child: widget.child,
    );
  }
}
