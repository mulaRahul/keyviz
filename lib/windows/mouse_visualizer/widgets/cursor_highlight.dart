import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/extensions.dart';
import 'package:keyviz/providers/providers.dart';

// abstract class to implemented by cursor higlights
abstract class CursorHighlight extends StatelessWidget {
  const CursorHighlight({
    super.key,
    required this.clicked,
    required this.keepHighlight,
  });

  final bool clicked;
  final bool keepHighlight;

  // utility getter click size
  double highlightSize(BuildContext context) {
    return context.select<KeyStyleProvider, double>(
      (style) => style.cursorHighlightSize,
    );
  }

  // utility getter click color
  Color color(BuildContext context) {
    return context.select<KeyStyleProvider, Color>(
      (style) => style.clickColor,
    );
  }

  // utility getter animation duration
  Duration animationDuration(BuildContext context) =>
      context.keyEvent.animationDuration;
}
