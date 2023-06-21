import 'package:flutter/material.dart';

import 'package:keyviz/config/style.dart';

class VerySmallRowGap extends StatelessWidget {
  const VerySmallRowGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: defaultPadding * .6);
  }
}

class SmallRowGap extends StatelessWidget {
  const SmallRowGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: defaultPadding);
  }
}

class RowGap extends StatelessWidget {
  const RowGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: defaultPadding * 2);
  }
}

class VerySmallColumnGap extends StatelessWidget {
  const VerySmallColumnGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: defaultPadding * .6);
  }
}

class SmallColumnGap extends StatelessWidget {
  const SmallColumnGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: defaultPadding);
  }
}

class ColumnGap extends StatelessWidget {
  const ColumnGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: defaultPadding * 2);
  }
}
