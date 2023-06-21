import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/shared.dart';

class XExpansionTile extends StatefulWidget {
  const XExpansionTile({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  State<XExpansionTile> createState() => _XExpansionTileState();
}

class _XExpansionTileState extends State<XExpansionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.theme.copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Text(
          widget.title,
          style: context.textTheme.titleMedium,
        ),
        tilePadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        leading: AnimatedRotation(
          turns: _expanded ? 0 : -.25,
          duration: transitionDuration,
          curve: Curves.easeOutCubic,
          child: const SvgIcon.chevronDown(size: defaultPadding * .4),
        ),
        childrenPadding: const EdgeInsets.only(left: defaultPadding * 2.25),
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < widget.children.length; i++)
            widget.children[i] is VerySmallColumnGap
                ? widget.children[i] // don't animate column gap
                : widget.children[i]
                    .animate(target: _expanded ? 1 : 0)
                    .fadeIn(delay: 75.ms * i)
        ],
        onExpansionChanged: (expanded) => setState(() => _expanded = expanded),
      ),
    );
  }
}
