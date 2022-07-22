import 'package:flutter/material.dart';

import '../data/properties.dart';

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
