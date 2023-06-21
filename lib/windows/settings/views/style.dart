import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/shared.dart';
import '../widgets/widgets.dart';

class StyleTabView extends StatelessWidget {
  const StyleTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PanelItem(
          title: "Preset",
          action: XDropdown(
            option: "Elevated",
            options: ["Minimal", "Flat", "Elevated", "Isometric"],
          ),
        ),
        const Divider(),
        // typography
        XExpansionTile(
          title: "Typography",
          children: [
            SubPanelItemGroup(
              items: [
                RawInputSubPanelItem(
                  title: "Size",
                  suffix: "px",
                  defaultValue: 16,
                  onChanged: (value) {},
                ),
                RawColorInputSubPanelItem(
                  defaultValue: Colors.amber,
                  onChanged: (color) {},
                ),
              ],
            ),
            const VerySmallColumnGap(),
            SubPanelItemGroup(
              items: [
                RawSubPanelItem(
                  title: "Caps",
                  child: Row(
                    children: [
                      Text(
                        "TT",
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.tertiary,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SmallRowGap(),
                      Text(
                        "Tt",
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SmallRowGap(),
                      Text(
                        "tt",
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.tertiary,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                const RawSubPanelItem(
                  title: "Modifier",
                  child: SizedBox(
                    width: defaultPadding * 5,
                    child: XDropdown(
                      option: "Icon Only",
                      decorated: false,
                      options: ["Icon Only", "Short Text", "Full Text"],
                    ),
                  ),
                ),
              ],
            ),
            const VerySmallColumnGap(),
          ],
        ),
        const Divider(),
        // layout
        XExpansionTile(
          title: "Layout",
          children: [
            SubPanelItemGroup(
              items: [
                // vertical align
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    XIconButton(
                      icon: VuesaxIcons.alignTop,
                      onTap: () {},
                      selected: false,
                    ),
                    const SmallRowGap(),
                    XIconButton(
                      icon: VuesaxIcons.alignVertically,
                      onTap: () {},
                      selected: true,
                    ),
                    const SmallRowGap(),
                    XIconButton(
                      icon: VuesaxIcons.alignBottom,
                      onTap: () {},
                      selected: false,
                    ),
                  ],
                ),
                // horizontal align
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    XIconButton(
                      icon: VuesaxIcons.alignLeft,
                      onTap: () {},
                      selected: false,
                    ),
                    const SmallRowGap(),
                    XIconButton(
                      icon: VuesaxIcons.alignHorizontally,
                      onTap: () {},
                      selected: true,
                    ),
                    const SmallRowGap(),
                    XIconButton(
                      icon: VuesaxIcons.alignRight,
                      onTap: () {},
                      selected: false,
                    ),
                  ],
                ),
              ],
            ),
            const VerySmallColumnGap(),
            SubPanelItemGroup(
              items: [
                RawSubPanelItem(
                  title: "Icon",
                  child: XSwitch(
                    defaultValue: true,
                    onChange: (v) {},
                  ),
                ),
                RawColorInputSubPanelItem(
                  defaultValue: Colors.black,
                  onChanged: (color) {},
                ),
              ],
            ),
            const VerySmallColumnGap(),
            SubPanelItemGroup(
              items: [
                RawSubPanelItem(
                  title: "Symbol",
                  child: XSwitch(
                    onChange: (v) {},
                  ),
                ),
                RawColorInputSubPanelItem(
                  defaultValue: Colors.black,
                  onChanged: (color) {},
                  enabled: false,
                ),
              ],
            ),
            const VerySmallColumnGap(),
            SubPanelItem(
              title: 'Add  "+"  Separator',
              child: XSwitch(
                onChange: (v) {},
              ),
            ),
          ],
        ),
        const Divider(),
        // color
        XExpansionTile(
          title: "Color",
          children: [
            SubPanelItem(
              title: "Fill Type",
              child: Row(
                children: [
                  XTextButton(
                    "Solid",
                    onTap: () {},
                    selected: true,
                  ),
                  const VerySmallRowGap(),
                  XTextButton(
                    "Gradient",
                    onTap: () {},
                    selected: false,
                  ),
                ],
              ),
            ),
            const VerySmallColumnGap(),
            // Padding(
            //   padding: const EdgeInsets.only(
            //     left: defaultPadding * .5,
            //     bottom: defaultPadding * .5,
            //   ),
            //   child: Text(
            //     "Normal Keys",
            //     style: context.textTheme.titleSmall?.copyWith(
            //       color: context.colorScheme.tertiary,
            //     ),
            //   ),
            // ),
            SubPanelItem(
              title: "Normal",
              child: SizedBox(
                width: defaultPadding * 10,
                child: RawColorInputSubPanelItem(
                  defaultValue: Colors.purple,
                  onChanged: (Color value) {},
                ),
              ),
            ),
            const VerySmallColumnGap(),
            SubPanelItem(
              title: "Modifier",
              child: SizedBox(
                width: defaultPadding * 10,
                child: RawColorInputSubPanelItem(
                  defaultValue: Colors.purple,
                  onChanged: (Color value) {},
                ),
              ),
            ),
          ],
        ),
        const Divider(),
        XExpansionTile(
          title: "Border",
          children: [
            SubPanelItemGroup(
              items: [
                RawSubPanelItem(
                  title: "Enable",
                  child: XSwitch(
                    onChange: (bool value) {},
                  ),
                ),
                RawColorInputSubPanelItem(
                  defaultValue: Colors.blueGrey,
                  onChanged: (color) {},
                  enabled: false,
                ),
              ],
            ),
            VerySmallColumnGap(),
            // TODO SliderInputSubPanelItem
            VerySmallColumnGap(),
          ],
        ),
        const Divider(),
        XExpansionTile(
          title: "Background",
          children: [
            SubPanelItemGroup(
              items: [
                RawSubPanelItem(
                  title: "Enable",
                  child: XSwitch(
                    defaultValue: true,
                    onChange: (bool value) {},
                  ),
                ),
                RawColorInputSubPanelItem(
                  defaultValue: Colors.lime,
                  onChanged: (Color value) {},
                ),
              ],
            ),
          ],
        ),
        const ColumnGap(),
      ],
    );
  }
}
