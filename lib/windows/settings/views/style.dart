import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/settings/widgets/cross_slider.dart';
import 'package:keyviz/windows/shared/shared.dart';
import '../widgets/widgets.dart';

class StyleTabView extends StatelessWidget {
  const StyleTabView({super.key});

  @override
  Widget build(BuildContext context) {
    const bool linked = true;
    const bool isFlat = false;
    const bool isSolid = false;
    const div = Divider(height: defaultPadding);

    return Column(
      children: [
        // preset
        const Padding(
          padding: EdgeInsets.only(bottom: defaultPadding),
          child: PanelItem(
            title: "Preset",
            action: XDropdown(
              option: "Elevated",
              options: ["Minimal", "Flat", "Elevated", "Isometric"],
            ),
          ),
        ),
        div,
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
                  label: "Font Color",
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
          ],
        ),
        div,
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
            SubPanelItem(
              title: "Icon",
              child: XSwitch(
                defaultValue: true,
                onChange: (v) {},
              ),
            ),
            const VerySmallColumnGap(),
            SubPanelItem(
              title: "Symbol",
              child: XSwitch(
                defaultValue: true,
                onChange: (v) {},
              ),
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
        div,
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
            // normal & modifiers title
            Padding(
              padding: const EdgeInsets.only(
                left: defaultPadding * .5,
                bottom: defaultPadding * .5,
              ),
              child: Row(
                children: [
                  Text(
                    "Normal",
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colorScheme.tertiary,
                    ),
                  ),
                  const VerySmallRowGap(),
                  IconButton(
                    onPressed: () {},
                    icon: const SvgIcon(
                      icon: linked ? VuesaxIcons.linked : VuesaxIcons.unlinked,
                    ),
                  ),
                  const VerySmallRowGap(),
                  Text(
                    "Modifier",
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colorScheme.tertiary
                          .withOpacity(linked ? 1 : .25),
                    ),
                  ),
                ],
              ),
            ),
            // color options
            if (isSolid) ...[
              SubPanelItem(
                title: "Color",
                child: SizedBox(
                  width: defaultPadding * 10,
                  child: RawColorInputSubPanelItem(
                    defaultValue: Colors.purple,
                    onChanged: (Color value) {},
                  ),
                ),
              ),
              if (!isFlat) ...[
                const VerySmallColumnGap(),
                SubPanelItem(
                  title: "Shadow",
                  child: SizedBox(
                    width: defaultPadding * 10,
                    child: RawColorInputSubPanelItem(
                      defaultValue: Colors.purple,
                      onChanged: (Color value) {},
                    ),
                  ),
                )
              ]
            ]
            // gradient
            else
              SubPanelItemGroup(
                items: [
                  RawGradientInputSubPanelItem(
                    title: "Primary Color",
                    onColor1Changed: (Color color) {},
                    onColor2Changed: (Color color) {},
                  ),
                  RawGradientInputSubPanelItem(
                    title: "Shadow Color",
                    onColor1Changed: (Color color) {},
                    onColor2Changed: (Color color) {},
                  ),
                ],
              ),
            const VerySmallColumnGap(),
            if (!linked) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: defaultPadding * .5,
                  left: defaultPadding * .5,
                  bottom: defaultPadding * .5,
                ),
                child: Text(
                  "Modifier",
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colorScheme.tertiary,
                  ),
                ),
              ),
              SubPanelItem(
                title: "Color",
                child: SizedBox(
                  width: defaultPadding * 10,
                  child: RawColorInputSubPanelItem(
                    defaultValue: Colors.purple,
                    onChanged: (Color value) {},
                  ),
                ),
              ),
            ]
          ],
        ),
        div,
        // border
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
                // ? if modifier and normal linked
                RawColorInputSubPanelItem(
                  enabled: false,
                  label: "Border Color",
                  defaultValue: Colors.blueGrey,
                  onChanged: (color) {},
                ),
              ],
            ),
            // ...[
            //   const VerySmallColumnGap(),
            //   SubPanelItem(
            //     title: "Normal",
            //     child: SizedBox(
            //       width: defaultPadding * 10,
            //       child: RawColorInputSubPanelItem(
            //         label: "Normal Border Color",
            //         onChanged: (color) {},
            //         defaultValue: Colors.black,
            //       ),
            //     ),
            //   ),
            //   const VerySmallColumnGap(),
            //   SubPanelItem(
            //     title: "Modifier",
            //     child: SizedBox(
            //       width: defaultPadding * 10,
            //       child: RawColorInputSubPanelItem(
            //         label: "Modifier Border Color",
            //         onChanged: (color) {},
            //         defaultValue: Colors.deepPurple,
            //       ),
            //     ),
            //   ),
            // ],
            const VerySmallColumnGap(),
            SubPanelItem(
              title: "Thickness",
              child: XSlider(
                onChanged: (int value) {},
                suffix: "px",
              ),
            ),
            const VerySmallColumnGap(),
            SubPanelItem(
              title: "Rounded Corner",
              child: XSlider(
                max: 100,
                onChanged: (int value) {},
                suffix: "%",
              ),
            ),
          ],
        ),
        div,
        // background
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
                  label: "Background Color",
                  defaultValue: Colors.lime,
                  onChanged: (Color value) {},
                ),
              ],
            ),
            const VerySmallColumnGap(),
            SubPanelItem(
              title: "Opacity",
              child: XSlider(
                max: 100,
                suffix: "%",
                onChanged: (int value) {},
              ),
            ),
          ],
        ),
        const SmallColumnGap(),
      ],
    );
  }
}
