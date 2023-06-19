import 'package:flutter/material.dart';


class KeyvizApp extends StatelessWidget {
  const KeyvizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Keyviz",
      home: Scaffold(
        body: Center(
          child: Text("Keyviz"),
        ),
      ),
    );
  }
}