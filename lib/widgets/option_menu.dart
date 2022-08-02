import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyviz/data/properties.dart';

class OptionMenu extends StatefulWidget {
  final bool isColorOptions;
  final List<String> options;
  final String? selectedOption;
  final Function(String) onChanged;

  const OptionMenu({
    Key? key,
    this.selectedOption,
    required this.options,
    required this.onChanged,
    this.isColorOptions = false,
  }) : super(key: key);

  @override
  State<OptionMenu> createState() => _OptionMenuState();
}

class _OptionMenuState extends State<OptionMenu> {
  late String selectedOption;

  @override
  void initState() {
    selectedOption = widget.selectedOption ?? widget.options[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 196,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: darkerGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: DropdownButton<String>(
        isDense: true,
        value: selectedOption,
        items: widget.options
            .map(
              (String option) => DropdownMenuItem(
                value: option,
                child: widget.isColorOptions
                    ? Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: colorFromHex(
                                  hexcodes[option] ?? "0xff000000"),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Text(
                            option,
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      )
                    : Text(
                        option,
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            )
            .toList(),
        onChanged: (String? option) {
          setState(
            () => selectedOption = option ?? selectedOption,
          );
          widget.onChanged(selectedOption);
        },
        menuMaxHeight: 512,
        borderRadius: BorderRadius.circular(16),
        dropdownColor: darkerGrey,
        underline: const SizedBox(),
        focusColor: Colors.white,
        isExpanded: true,
        icon: SvgPicture.asset(
          "assets/img/arrow-down.svg",
          width: 12,
          color: darkGrey,
        ),
      ),
    );
  }
}

class ColorMenu extends StatefulWidget {
  final List<String> options;
  final String? selectedOption;
  final Function(String) onChanged;

  const ColorMenu({
    Key? key,
    required this.onChanged,
    this.selectedOption,
    required this.options,
  }) : super(key: key);

  @override
  State<ColorMenu> createState() => _ColorMenuState();
}

class _ColorMenuState extends State<ColorMenu> {
  late String selectedOption;

  @override
  void initState() {
    selectedOption = widget.selectedOption ?? widget.options[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 196,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
      decoration: BoxDecoration(
        color: darkerGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: DropdownButton<String>(
        isDense: true,
        value: selectedOption,
        items: widget.options
            .map(
              (String option) => DropdownMenuItem(
                  value: option,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: keycapThemes[option]!.baseColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text("A",
                            style: TextStyle(
                              fontSize: 12,
                              color: keycapThemes[option]!.fontColor,
                            )),
                      ),
                      Text(option, style: const TextStyle(color: Colors.white))
                    ],
                  )),
            )
            .toList(),
        onChanged: (String? option) {
          setState(
            () => selectedOption = option ?? selectedOption,
          );
          widget.onChanged(selectedOption);
        },
        menuMaxHeight: 512,
        borderRadius: BorderRadius.circular(16),
        dropdownColor: darkerGrey,
        underline: const SizedBox(),
        focusColor: Colors.white,
        isExpanded: true,
        icon: SvgPicture.asset(
          "assets/img/arrow-down.svg",
          width: 12,
          color: darkGrey,
        ),
      ),
    );
  }
}
