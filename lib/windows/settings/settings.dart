import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';

class SettingsWindow extends StatelessWidget {
  const SettingsWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 544,
      decoration: BoxDecoration(
        color: context.colorScheme.background,
      ),
    );
  }
}
