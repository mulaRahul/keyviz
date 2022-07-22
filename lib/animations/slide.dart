import 'package:flutter/material.dart';

import '../data/config.dart';

class SlideUpAnimation extends StatefulWidget {
  final Widget child;
  final bool skipTransition;

  const SlideUpAnimation({
    Key? key,
    required this.child,
    this.skipTransition = false,
  }) : super(key: key);

  @override
  State<SlideUpAnimation> createState() => SlideUpAnimationState();
}

class SlideUpAnimationState extends State<SlideUpAnimation> {
  late double dy;
  late GlobalKey key;

  @override
  void initState() {
    dy = widget.skipTransition ? 0 : 1.6;
    super.initState();
  }

  void animateIn() => setState(() => dy = 0);
  void animateOut() => setState(() => dy = 1.6);

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset(0, dy),
      curve: Curves.easeOutQuart,
      duration: configData.transitionDuration,
      child: widget.child,
    );
  }
}
