import 'package:flutter/material.dart';
import 'package:keyviz/data/config.dart';

import '../data/properties.dart';

class AlignmentPicker extends StatefulWidget {
  final double margin;

  const AlignmentPicker({
    Key? key,
    required this.margin,
  }) : super(key: key);

  @override
  State<AlignmentPicker> createState() => _AlignmentPickerState();
}

class _AlignmentPickerState extends State<AlignmentPicker> {
  late String _alignment;
  double hovered = 0;

  @override
  void initState() {
    super.initState();

    if (configData.alignment == Alignment.bottomLeft) {
      _alignment = "left";
    } else if (configData.alignment == Alignment.bottomCenter) {
      _alignment = "center";
    } else if (configData.alignment == Alignment.bottomRight) {
      _alignment = "right";
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = 1),
      onExit: (_) => setState(() => hovered = 0),
      child: Column(
        children: [
          AnimatedContainer(
            duration: configData.transitionDuration,
            curve: Curves.easeOutCubic,
            width: 240,
            height: 135,
            padding: EdgeInsets.all(widget.margin / 8),
            alignment: Alignment.bottomCenter,
            decoration: const BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  image: AssetImage("assets/img/wallpaper.jpg"),
                  fit: BoxFit.cover),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ["left", "center", "right"]
                  .map(
                    (String option) => AnimatedOpacity(
                      duration: configData.transitionDuration,
                      curve: Curves.easeOutQuart,
                      opacity: _alignment == option ? 1 : hovered,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _alignment = option);
                          configData.alignment = alignmentFrom[option]!;
                        },
                        child: AlignmentOption(
                          text: option,
                          selected: _alignment == option,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Container(
            width: 240,
            height: 12,
            decoration: const BoxDecoration(
              color: darkerGrey,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}

class AlignmentOption extends StatelessWidget {
  final String text;

  const AlignmentOption({
    Key? key,
    required this.selected,
    required this.text,
  }) : super(key: key);

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: configData.transitionDuration,
      curve: Curves.easeOutQuad,
      width: 64,
      height: 40,
      decoration: BoxDecoration(
        color: selected ? Colors.black : grey.withOpacity(.5),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
