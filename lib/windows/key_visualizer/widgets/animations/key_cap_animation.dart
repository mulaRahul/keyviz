import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/providers/key_event.dart';

// abstract class to be implement by KeyCapAnimations
abstract class KeyCapAnimation extends StatelessWidget {
  const KeyCapAnimation({super.key, required this.show, required this.child});

  // animation in/out state
  final bool show;

  // key cap widget
  final Widget child;

  // utility getter for animation duration
  Duration animationDuration(BuildContext context) =>
      context.read<KeyEventProvider>().animationDuration;
}
