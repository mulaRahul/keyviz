import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyviz/config/config.dart';

class XDropdown extends StatefulWidget {
  const XDropdown({
    super.key,
    required this.option,
    required this.options,
    this.decorated = true,
  });

  final String option;
  final List<String> options;
  final bool decorated;

  @override
  State<XDropdown> createState() => _XDropdownState();
}

class _XDropdownState extends State<XDropdown> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.option;
  }

  @override
  Widget build(BuildContext context) {
    final child = DropdownButton(
      value: _value,
      items: [
        for (final option in widget.options)
          DropdownMenuItem(
            value: option,
            child: Text(option),
          ),
      ],
      onChanged: (v) => v != null ? setState(() => _value = v) : null,
      // style
      isDense: true,
      isExpanded: true,
      padding: widget.decorated
          ? const EdgeInsets.symmetric(
              horizontal: defaultPadding * .5,
              vertical: defaultPadding * .2,
            )
          : EdgeInsets.zero,
      borderRadius: BorderRadius.circular(defaultPadding * .6),
      dropdownColor: context.colorScheme.primaryContainer,
      style: context.textTheme.labelSmall?.copyWith(
        fontSize: defaultPadding * .75,
      ),
      icon: SvgPicture.asset(
        VuesaxIcons.chevronDown,
        colorFilter: ColorFilter.mode(
          context.colorScheme.secondary,
          BlendMode.srcIn,
        ),
      ),
      underline: const SizedBox(),
    );

    return widget.decorated
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(defaultPadding * .6),
              border: Border.all(color: context.colorScheme.outline),
            ),
            child: child,
          )
        : child;
  }
}
