import 'package:flutter/material.dart';

import '../animations/backdrop.dart';
import '../data/config.dart';

class KeycaptureView extends StatelessWidget {
  final bool noPadding;

  const KeycaptureView({
    Key? key,
    this.noPadding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return noPadding
        ? const AnimatedBackdrop()
        : Padding(
            padding: EdgeInsets.all(configData.margin),
            child: AnimatedAlign(
              curve: Curves.easeOutCirc,
              alignment: configData.alignment,
              duration: configData.transitionDuration,
              child: const AnimatedBackdrop(),
            ),
          );
  }
}
