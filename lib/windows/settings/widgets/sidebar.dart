import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:keyviz/config/config.dart';

enum SettingsTab {
  general(VuesaxIcons.cogWheel),
  mouse(VuesaxIcons.mouse),
  style(VuesaxIcons.edit),
  apperance(VuesaxIcons.monitor),
  about(VuesaxIcons.more);

  const SettingsTab(this.icon);
  final String icon;
}

class SideBar extends StatelessWidget {
  const SideBar({
    super.key,
    required this.currentTab,
    required this.onChange,
  });

  final SettingsTab currentTab;
  final void Function(SettingsTab tab) onChange;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    const tabs = SettingsTab.values;

    for (int i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      // position conditions
      final isFirst = i == 0;
      final isLast = i == tabs.length - 1;

      // add spacing between buttons
      if (!isFirst) {
        // push the About button to the end
        if (isLast) {
          children.add(const Spacer());
        }
        // add column gap
        else {
          children.add(const SizedBox(height: defaultPadding * .25));
        }
      }

      // add icon button
      children.add(
        _IconButton(
          icon: tab.icon,
          label: tab.name,
          onTap: () => onChange(tab),
          selected: currentTab == tab,
        ),
      );
    }

    return Column(children: children);
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.selected,
    this.size = 40.0,
  });

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.secondaryContainer
              : context.colorScheme.secondaryContainer.withOpacity(0),
          borderRadius: BorderRadius.circular(defaultPadding / 2),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          icon,
          width: size * .44,
          height: size * .44,
          colorFilter: ColorFilter.mode(
            selected
                ? context.colorScheme.primary
                : context.colorScheme.tertiary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
