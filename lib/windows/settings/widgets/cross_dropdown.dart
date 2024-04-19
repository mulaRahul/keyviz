import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyviz/config/config.dart';

class XDropdown<T> extends StatelessWidget {
  const XDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.decorated = true,
    this.labelBuilder,
  });

  final T value;
  final bool decorated;
  final List<T> options;
  final String Function(T option)? labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final child = DropdownButton(
      value: value,
      items: [
        for (final option in options)
          DropdownMenuItem(
            value: option,
            child: Text(labelBuilder?.call(option) ?? option.toString()),
          ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      // style
      isDense: true,
      isExpanded: true,
      padding: decorated
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

    return decorated
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
