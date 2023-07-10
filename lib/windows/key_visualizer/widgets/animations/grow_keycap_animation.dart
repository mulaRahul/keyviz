import 'package:flutter/material.dart';

import 'key_cap_animation.dart';

class GrowKeyCapAnimation extends KeyCapAnimation {
  const GrowKeyCapAnimation({
    super.key,
    required super.show,
    required super.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: animationDuration(context),
      curve: Curves.easeInOutCubicEmphasized,
      scale: show ? 1 : 0,
      child: child,
    );
  }
}
