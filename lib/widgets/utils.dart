import 'package:flutter/material.dart';

import '../data/properties.dart';

class ListItem extends StatelessWidget {
  final List<Widget> children;
  final String? description;
  final CrossAxisAlignment alignment;
  final double topRadius;
  final double bottomRadius;
  final double bottomMargin;

  const ListItem({
    Key? key,
    required this.children,
    this.description,
    this.topRadius = 0,
    this.bottomRadius = 0,
    this.bottomMargin = 2,
    this.alignment = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 20,
      ),
      margin: EdgeInsets.only(bottom: bottomMargin),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(topRadius),
          bottom: Radius.circular(bottomRadius),
        ),
      ),
      child: description == null
          ? Row(
              crossAxisAlignment: alignment,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: children,
                ),
                const Space(),
                Text(description!, style: captionStyle),
              ],
            ),
    );
  }
}

class Label extends StatelessWidget {
  final double width;
  final String? text;
  final Widget? child;
  final double topMargin;

  const Label({
    Key? key,
    this.child,
    this.text,
    this.width = 144,
    this.topMargin = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 32, top: topMargin),
      alignment: Alignment.centerRight,
      width: width,
      child: child ??
          Text(
            text!,
            style: headingStyle,
            textAlign: TextAlign.right,
          ),
    );
  }
}

class Space extends StatelessWidget {
  const Space({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 16);
  }
}
