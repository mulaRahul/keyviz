import 'package:flutter/material.dart';

import 'key_cap_animation.dart';

class FadeKeyCapAnimation extends KeyCapAnimation {
  const FadeKeyCapAnimation({
    super.key,
    required super.show,
    required super.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: animationDuration(context),
      curve: Curves.easeInOut,
      opacity: show ? 1 : 0,
      child: child,
    );
  }
}
