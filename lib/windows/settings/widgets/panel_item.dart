import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';

class PanelItem extends StatelessWidget {
  const PanelItem({
    super.key,
    required this.title,
    required this.action,
    this.asRow = true,
    this.enabled = true,
    this.subtitle,
    this.actionFlex = 1,
    this.crossAxisAlignment,
  });

  final String title;
  final String? subtitle;
  final Widget action;
  final bool asRow;
  final bool enabled;
  final int actionFlex;
  final CrossAxisAlignment? crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final label = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: defaultPadding * .25),
        if (subtitle != null)
          Text(
            subtitle!,
            style: context.textTheme.bodyMedium,
          ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : .4,
      child: asRow
          ? Row(
              crossAxisAlignment: crossAxisAlignment ??
                  (subtitle == null
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start),
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: defaultPadding * .5),
                    child: label,
                  ),
                ),
                Expanded(
                  flex: actionFlex,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IgnorePointer(
                      ignoring: !enabled,
                      child: action,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment:
                  crossAxisAlignment ?? CrossAxisAlignment.start,
              children: [
                label,
                const SizedBox(height: defaultPadding * .75),
                IgnorePointer(ignoring: !enabled, child: action),
              ],
            ),
    );
  }
}
