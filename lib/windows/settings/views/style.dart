import 'package:flutter/material.dart';
import 'package:keyviz/providers/key_event.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_style.dart';
import 'package:keyviz/windows/shared/shared.dart';
import 'package:tuple/tuple.dart';

import '../widgets/widgets.dart';

class StyleTabView extends StatelessWidget {
  const StyleTabView({super.key});

  @override
  Widget build(BuildContext context) {
    const div = Divider(height: defaultPadding);

    return Column(
      children: [
        // preset
        Padding(
          padding: const EdgeInsets.only(bottom: defaultPadding),
          child: PanelItem(
            title: "Preset",
            action: Selector<KeyStyleProvider, KeyCapStyle>(
              selector: (_, keyStyle) => keyStyle.preset,
              builder: (context, preset, _) {
                return XDropdown<KeyCapStyle>(
                  value: preset,
                  options: KeyCapStyle.values,
                  onChanged: (value) => context.keyStyle.preset = value,
                );
              },
            ),
          ),
        ),
        div,
        // typography
        XExpansionTile(
          title: "Typography",
          children: [
            Selector<KeyStyleProvider, bool>(
              selector: (_, keyStyle) => keyStyle.differentColorForModifiers,
              builder: (context, differentColorForModifiers, _) {
                return differentColorForModifiers
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SubPanelItem(
                            title: "Font Size",
                            child: Selector<KeyStyleProvider, double>(
                              selector: (_, keyStyle) => keyStyle.fontSize,
                              builder: (context, fontSize, _) => XSlider(
                                max: 128,
                                suffix: "px",
                                value: fontSize,
                                onChanged: (value) {
                                  context.keyStyle.fontSize = value;
                                },
                              ),
                            ),
                          ),
                          const VerySmallColumnGap(),
                          SubPanelItem(
                            title: "Normal Color",
                            child: SizedBox(
                              width: defaultPadding * 10,
                              child: RawColorInputSubPanelItem(
                                label: "Normal Font Color",
                                defaultValue: context.keyStyle.fontColor,
                                onChanged: (Color value) {
                                  context.keyStyle.fontColor = value;
                                },
                              ),
                            ),
                          ),
                          const VerySmallColumnGap(),
                          SubPanelItem(
                            title: "Modifier Color",
                            child: SizedBox(
                              width: defaultPadding * 10,
                              child: RawColorInputSubPanelItem(
                                label: "Modifier Font Color",
                                defaultValue: context.keyStyle.mFontColor,
                                onChanged: (Color value) {
                                  context.keyStyle.mFontColor = value;
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    : SubPanelItemGroup(
                        items: [
                          RawInputSubPanelItem(
                            title: "Size",
                            suffix: "px",
                            defaultValue: context.keyStyle.fontSize.toInt(),
                            onChanged: (value) {
                              context.keyStyle.fontSize = value.toDouble();
                            },
                          ),
                          RawColorInputSubPanelItem(
                            label: "Font Color",
                            defaultValue: context.keyStyle.fontColor,
                            onChanged: (color) {
                              context.keyStyle.fontColor = color;
                            },
                          ),
                        ],
                      );
              },
            ),
            const VerySmallColumnGap(),
            SubPanelItemGroup(
              items: [
                RawSubPanelItem(
                  title: "Caps",
                  child: Selector<KeyStyleProvider, TextCap>(
                    selector: (_, keyStyle) => keyStyle.textCap,
                    builder: (context, textCap, _) => Row(
                      children: [
                        for (final value in TextCap.values)
                          Tooltip(
                            message: value.toString(),
                            child: TextButton(
                              onPressed: () {
                                context.keyStyle.textCap = value;
                              },
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                  vertical: defaultPadding * .25,
                                  horizontal: defaultPadding * .5,
                                ),
                              ),
                              child: Text(
                                value.symbol,
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: value == textCap
                                      ? context.colorScheme.primary
                                      : context.colorScheme.tertiary,
                                  fontWeight: value == textCap
                                      ? FontWeight.w700
                                      : FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                RawSubPanelItem(
                  title: "Modifier",
                  child: SizedBox(
                    width: defaultPadding * 5,
                    child: Selector<KeyStyleProvider, ModifierTextLength>(
                      selector: (_, keyStyle) => keyStyle.modifierTextLength,
                      builder: (context, modifierTextLength, _) {
                        return XDropdown<ModifierTextLength>(
                          decorated: false,
                          value: modifierTextLength,
                          options: ModifierTextLength.values,
                          onChanged: (value) {
                            context.keyStyle.modifierTextLength = value;
                          },
                        );
                      },
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
                    for (final value in VerticalAlignment.values)
                      Padding(
                        padding: EdgeInsets.only(
                          right: value == VerticalAlignment.values.last
                              ? 0
                              : defaultPadding,
                        ),
                        child: Selector<KeyStyleProvider, VerticalAlignment>(
                          selector: (_, keyStyle) => keyStyle.verticalAlignment,
                          builder: (context, verticalAlignment, _) {
                            return XIconButton(
                              icon: value.iconName,
                              onTap: () {
                                context.keyStyle.verticalAlignment = value;
                              },
                              selected: verticalAlignment == value,
                            );
                          },
                        ),
                      ),
                  ],
                ),
                // horizontal align
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final value in HorizontalAlignment.values)
                      Padding(
                        padding: EdgeInsets.only(
                          right: value == HorizontalAlignment.values.last
                              ? 0
                              : defaultPadding,
                        ),
                        child: Selector<KeyStyleProvider, HorizontalAlignment>(
                          selector: (_, keyStyle) {
                            return keyStyle.horizontalAlignment;
                          },
                          builder: (context, horizontalAlignment, _) {
                            return XIconButton(
                              icon: value.iconName,
                              onTap: () {
                                context.keyStyle.horizontalAlignment = value;
                              },
                              selected: horizontalAlignment == value,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const VerySmallColumnGap(),
            SubPanelItem(
              title: "Icon",
              child: Selector<KeyStyleProvider, bool>(
                selector: (_, keyStyle) => keyStyle.showIcon,
                builder: (context, showIcon, _) {
                  return XSwitch(
                    value: showIcon,
                    onChange: (value) => context.keyStyle.showIcon = value,
                  );
                },
              ),
            ),
            const VerySmallColumnGap(),
            SubPanelItem(
              title: "Symbol",
              child: Selector<KeyStyleProvider, bool>(
                selector: (_, keyStyle) => keyStyle.showSymbol,
                builder: (context, showSymbol, _) {
                  return XSwitch(
                    value: showSymbol,
                    onChange: (value) => context.keyStyle.showSymbol = value,
                  );
                },
              ),
            ),
            const VerySmallColumnGap(),
            SubPanelItem(
              title: 'Add  "+"  Separator',
              child: Selector<KeyStyleProvider, bool>(
                selector: (_, keyStyle) => keyStyle.addPlusSeparator,
                builder: (context, addPlusSeparator, _) {
                  return XSwitch(
                    value: addPlusSeparator,
                    onChange: (value) {
                      context.keyStyle.addPlusSeparator = value;
                    },
                  );
                },
              ),
            ),
          ],
        ),
        div,
        // color
        Selector<KeyStyleProvider, KeyCapStyle>(
          selector: (_, keyStyle) => keyStyle.preset,
          shouldRebuild: (previous, next) =>
              previous == KeyCapStyle.minimal || next == KeyCapStyle.minimal,
          builder: (context, preset, _) {
            return preset == KeyCapStyle.minimal
                ? const SizedBox()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      XExpansionTile(
                        title: "Color",
                        children: [
                          SubPanelItem(
                            title: "Fill Type",
                            child: Selector<KeyStyleProvider, bool>(
                              selector: (_, keyStyle) => keyStyle.isGradient,
                              builder: (context, isGradient, _) {
                                return Row(
                                  children: [
                                    XTextButton(
                                      "Solid",
                                      selected: !isGradient,
                                      onTap: () =>
                                          context.keyStyle.isGradient = false,
                                    ),
                                    const VerySmallRowGap(),
                                    Selector<KeyStyleProvider, KeyCapStyle>(
                                      selector: (_, keyStyle) =>
                                          keyStyle.preset,
                                      builder: (context, preset, _) {
                                        final isElevated =
                                            preset == KeyCapStyle.elevated;
                                        return isElevated
                                            ? Tooltip(
                                                message:
                                                    "Elevated style doesn't"
                                                    " support gradients",
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal:
                                                        defaultPadding * .6,
                                                  ),
                                                  child: Text(
                                                    "Gradient",
                                                    style: context
                                                        .textTheme.labelSmall
                                                        ?.copyWith(
                                                      fontSize: 14,
                                                      color: context
                                                          .colorScheme.tertiary
                                                          .withOpacity(.25),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : XTextButton(
                                                "Gradient",
                                                selected: isGradient,
                                                onTap: () => context
                                                    .keyStyle.isGradient = true,
                                              );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const VerySmallColumnGap(),
                          // normal & modifiers title
                          Padding(
                            padding: const EdgeInsets.only(
                              left: defaultPadding * .5,
                              bottom: defaultPadding * .5,
                            ),
                            child: Selector<KeyStyleProvider, bool>(
                              selector: (_, keyStyle) =>
                                  keyStyle.differentColorForModifiers,
                              builder: (context, differentColors, _) => Row(
                                children: [
                                  Text(
                                    "Normal",
                                    style:
                                        context.textTheme.titleSmall?.copyWith(
                                      color: context.colorScheme.tertiary,
                                    ),
                                  ),
                                  const VerySmallRowGap(),
                                  IconButton(
                                    onPressed: () {
                                      context.keyStyle
                                              .differentColorForModifiers =
                                          !differentColors;
                                    },
                                    icon: SvgIcon(
                                      icon: differentColors
                                          ? VuesaxIcons.unlinked
                                          : VuesaxIcons.linked,
                                    ),
                                  ),
                                  const VerySmallRowGap(),
                                  Text(
                                    "Modifier",
                                    style:
                                        context.textTheme.titleSmall?.copyWith(
                                      color: context.colorScheme.tertiary
                                          .withOpacity(
                                              differentColors ? .25 : 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // color options
                          Selector<KeyStyleProvider,
                              Tuple3<KeyCapStyle, bool, bool>>(
                            selector: (_, keyStyle) => Tuple3(
                              keyStyle.preset,
                              keyStyle.isGradient,
                              keyStyle.differentColorForModifiers,
                            ),
                            builder: (context, tuple, _) {
                              final bool need2Colors =
                                  tuple.item1 == KeyCapStyle.isometric ||
                                      tuple.item1 == KeyCapStyle.elevated;
                              final bool isGradient = tuple.item2;
                              final bool differentColorForModifiers =
                                  tuple.item3;

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // normal color options
                                  isGradient
                                      ? SubPanelItemGroup(
                                          items: [
                                            RawGradientInputSubPanelItem(
                                              title: need2Colors
                                                  ? "Primary"
                                                  : "Color",
                                              initialColor1: context
                                                  .keyStyle.primaryColor1,
                                              initialColor2: context
                                                  .keyStyle.primaryColor2,
                                              onColor1Changed: (Color color) {
                                                context.keyStyle.primaryColor1 =
                                                    color;
                                              },
                                              onColor2Changed: (Color color) {
                                                context.keyStyle.primaryColor2 =
                                                    color;
                                              },
                                            ),
                                            if (need2Colors)
                                              RawGradientInputSubPanelItem(
                                                title: "Secondary",
                                                initialColor1: context
                                                    .keyStyle.secondaryColor1,
                                                initialColor2: context
                                                    .keyStyle.secondaryColor2,
                                                onColor1Changed: (Color color) {
                                                  context.keyStyle
                                                      .secondaryColor1 = color;
                                                },
                                                onColor2Changed: (Color color) {
                                                  context.keyStyle
                                                      .secondaryColor2 = color;
                                                },
                                              ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SubPanelItem(
                                              title: need2Colors
                                                  ? "Primary"
                                                  : "Color",
                                              child: SizedBox(
                                                width: defaultPadding * 10,
                                                child:
                                                    RawColorInputSubPanelItem(
                                                  defaultValue: context
                                                      .keyStyle.primaryColor1,
                                                  onChanged: (Color color) {
                                                    context.keyStyle
                                                        .primaryColor1 = color;
                                                  },
                                                ),
                                              ),
                                            ),
                                            if (need2Colors) ...[
                                              const VerySmallColumnGap(),
                                              SubPanelItem(
                                                title: "Secondary",
                                                child: SizedBox(
                                                  width: defaultPadding * 10,
                                                  child:
                                                      RawColorInputSubPanelItem(
                                                    defaultValue: context
                                                        .keyStyle
                                                        .secondaryColor1,
                                                    onChanged: (Color color) {
                                                      context.keyStyle
                                                              .secondaryColor1 =
                                                          color;
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                  // modifier color options
                                  if (differentColorForModifiers) ...[
                                    const VerySmallColumnGap(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: defaultPadding * .5,
                                        left: defaultPadding * .5,
                                        bottom: defaultPadding * .5,
                                      ),
                                      child: Text(
                                        "Modifier",
                                        style: context.textTheme.titleSmall
                                            ?.copyWith(
                                          color: context.colorScheme.tertiary,
                                        ),
                                      ),
                                    ),
                                    isGradient
                                        ? SubPanelItemGroup(
                                            items: [
                                              RawGradientInputSubPanelItem(
                                                title: need2Colors
                                                    ? "Primary"
                                                    : "Color",
                                                initialColor1: context
                                                    .keyStyle.mPrimaryColor1,
                                                initialColor2: context
                                                    .keyStyle.mPrimaryColor2,
                                                onColor1Changed: (Color color) {
                                                  context.keyStyle
                                                      .mPrimaryColor1 = color;
                                                },
                                                onColor2Changed: (Color color) {
                                                  context.keyStyle
                                                      .mPrimaryColor2 = color;
                                                },
                                              ),
                                              if (need2Colors)
                                                RawGradientInputSubPanelItem(
                                                  title: "Secondary",
                                                  initialColor1: context
                                                      .keyStyle
                                                      .mSecondaryColor1,
                                                  initialColor2: context
                                                      .keyStyle
                                                      .mSecondaryColor2,
                                                  onColor1Changed:
                                                      (Color color) {
                                                    context.keyStyle
                                                            .mSecondaryColor1 =
                                                        color;
                                                  },
                                                  onColor2Changed:
                                                      (Color color) {
                                                    context.keyStyle
                                                            .mSecondaryColor2 =
                                                        color;
                                                  },
                                                ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SubPanelItem(
                                                title: need2Colors
                                                    ? "Primary"
                                                    : "Color",
                                                child: SizedBox(
                                                  width: defaultPadding * 10,
                                                  child:
                                                      RawColorInputSubPanelItem(
                                                    defaultValue: context
                                                        .keyStyle
                                                        .mPrimaryColor1,
                                                    onChanged: (Color color) {
                                                      context.keyStyle
                                                              .mPrimaryColor1 =
                                                          color;
                                                    },
                                                  ),
                                                ),
                                              ),
                                              if (need2Colors) ...[
                                                const VerySmallColumnGap(),
                                                SubPanelItem(
                                                  title: "Secondary",
                                                  child: SizedBox(
                                                    width: defaultPadding * 10,
                                                    child:
                                                        RawColorInputSubPanelItem(
                                                      defaultValue: context
                                                          .keyStyle
                                                          .mSecondaryColor1,
                                                      onChanged: (Color color) {
                                                        context.keyStyle
                                                                .mSecondaryColor1 =
                                                            color;
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                  ]
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      div,
                    ],
                  );
          },
        ),
        // border
        Selector<KeyStyleProvider, bool>(
          selector: (_, keyStyle) => keyStyle.borderEnabled,
          builder: (context, enabled, _) => XExpansionTile(
            title: "Border",
            children: [
              Selector<KeyStyleProvider, bool>(
                  selector: (_, keyStyle) =>
                      keyStyle.differentColorForModifiers,
                  builder: (context, differentColors, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SubPanelItemGroup(
                          items: [
                            RawSubPanelItem(
                              title: "Enable",
                              child: XSwitch(
                                value: enabled,
                                onChange: (value) {
                                  context.keyStyle.borderEnabled = value;
                                },
                              ),
                            ),
                            if (!differentColors)
                              RawColorInputSubPanelItem(
                                enabled: enabled,
                                label: "Border Color",
                                defaultValue: context.keyStyle.borderColor,
                                onChanged: (color) {
                                  context.keyStyle.borderColor = color;
                                },
                              ),
                          ],
                        ),
                        if (differentColors) ...[
                          const VerySmallColumnGap(),
                          SubPanelItem(
                            enabled: enabled,
                            title: "Normal",
                            child: SizedBox(
                              width: defaultPadding * 10,
                              child: RawColorInputSubPanelItem(
                                label: "Normal Border Color",
                                defaultValue: context.keyStyle.borderColor,
                                onChanged: (color) {
                                  context.keyStyle.borderColor = color;
                                },
                              ),
                            ),
                          ),
                          const VerySmallColumnGap(),
                          SubPanelItem(
                            enabled: enabled,
                            title: "Modifier",
                            child: SizedBox(
                              width: defaultPadding * 10,
                              child: RawColorInputSubPanelItem(
                                label: "Modifier Border Color",
                                defaultValue: context.keyStyle.mBorderColor,
                                onChanged: (color) {
                                  context.keyStyle.mBorderColor = color;
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
              const VerySmallColumnGap(),
              SubPanelItem(
                enabled: enabled,
                title: "Thickness",
                child: Selector<KeyStyleProvider, double>(
                  selector: (_, keyStyle) => keyStyle.borderWidth,
                  builder: (context, borderWidth, _) => XSlider(
                    suffix: "px",
                    min: 1,
                    max: 8,
                    value: borderWidth,
                    onChanged: (value) => context.keyStyle.borderWidth = value,
                  ),
                ),
              ),
              const VerySmallColumnGap(),
              SubPanelItem(
                title: "Rounded Corner",
                child: Selector<KeyStyleProvider, double>(
                  selector: (_, keyStyle) => keyStyle.cornerSmoothing,
                  builder: (context, cornerSmoothing, _) {
                    return XSlider(
                      max: 100,
                      suffix: "%",
                      value: cornerSmoothing,
                      onChanged: (value) {
                        context.keyStyle.cornerSmoothing = value;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        div,
        // background
        Selector<KeyStyleProvider, bool>(
          selector: (_, keyStyle) => keyStyle.backgroundEnabled,
          builder: (context, enabled, _) {
            return XExpansionTile(
              title: "Background",
              children: [
                SubPanelItemGroup(
                  items: [
                    RawSubPanelItem(
                      title: "Enable",
                      child: XSwitch(
                        value: enabled,
                        onChange: (value) {
                          context.keyStyle.backgroundEnabled = value;
                        },
                      ),
                    ),
                    RawColorInputSubPanelItem(
                      enabled: enabled,
                      label: "Background Color",
                      defaultValue: context.keyStyle.backgroundColor,
                      onChanged: (color) {
                        context.keyStyle.backgroundColor = color;
                      },
                    ),
                  ],
                ),
                const VerySmallColumnGap(),
                SubPanelItem(
                  title: "Opacity",
                  enabled: enabled,
                  child: Selector<KeyStyleProvider, double>(
                    selector: (_, keyStyle) => keyStyle.backgroundOpacity,
                    builder: (context, opacity, _) => XSlider(
                      max: 100,
                      suffix: "%",
                      value: opacity * 100,
                      onChanged: (value) {
                        context.keyStyle.backgroundOpacity = value / 100;
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SmallColumnGap(),
      ],
    );
  }
}
