import 'package:flutter/widgets.dart';
import 'package:keyviz/providers/key_event.dart';

// abstract class to be implemented by every key cap class
abstract class KeyCap extends StatelessWidget {
  const KeyCap({super.key, required this.event});

  // key event data
  final KeyEventData event;
}
