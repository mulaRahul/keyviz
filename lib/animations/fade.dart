import 'package:flutter/material.dart';

import '../data/config.dart';

class FadeAnimation extends StatefulWidget {
  final Widget child;
  final bool skipTransition;

  const FadeAnimation({
    Key? key,
    required this.child,
    this.skipTransition = false,
  }) : super(key: key);

  @override
  State<FadeAnimation> createState() => FadeAnimationState();
}

class FadeAnimationState extends State<FadeAnimation> {
  late double _end;

  @override
  void initState() {
    _end = widget.skipTransition ? 1 : 0;
    super.initState();
  }

  void animateIn() => setState(() => _end = 1);
  void animateOut() => setState(() => _end = 0);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: widget.skipTransition ? 1 : 0, end: _end),
      duration: configData.transitionDuration,
      curve: Curves.fastOutSlowIn,
      builder: (_, double animation, __) {
        return Opacity(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(64 * (1 - animation), 0),
            child: widget.child,
          ),
        );
      },
    );
  }
}
