import 'package:flutter/material.dart';

import 'key_cap_animation.dart';

class SlideKeyCapAnimation extends KeyCapAnimation {
  const SlideKeyCapAnimation({
    super.key,
    required super.show,
    required super.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: duration(context),
      curve: Curves.easeInOutCubicEmphasized,
      offset: Offset(0, show ? 0 : 1.2),
      child: child,
    );
  }
}
