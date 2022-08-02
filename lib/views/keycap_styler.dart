import 'package:flutter/material.dart';
import 'package:keyviz/data/properties.dart';
import 'package:provider/provider.dart';

import '../data/config.dart';
import '../providers/config.dart';
import '../widgets/iso_keycap.dart';
import '../widgets/solid_keycap.dart';

class KeycapStyler extends StatelessWidget {
  const KeycapStyler({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConfigDataProvider configDataProvider =
        Provider.of<ConfigDataProvider>(context);

    final Alignment alignment =
        configDataProvider.showIcon ? Alignment.centerRight : Alignment.center;

    return AnimatedContainer(
      duration: configData.transitionDuration,
      curve: Curves.fastOutSlowIn,
      padding: EdgeInsets.all(configDataProvider.size / 2),
      height: configDataProvider.size * 3.75,
      width: configDataProvider.size * 12.5,
      decoration: BoxDecoration(
        color: configDataProvider.borderColor,
        borderRadius: BorderRadius.circular(configDataProvider.size / 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: () {
          switch (configDataProvider.style) {
            case KeycapStyle.solid:
              return [
                SolidStyleKey(
                  width: configDataProvider.size * 4,
                  iconPath: configDataProvider.showIcon
                      ? "assets/symbols/control.svg"
                      : null,
                  keyName: configDataProvider.showIcon ? "control" : "Ctrl",
                  textAlignment: alignment,
                  baseColor: configDataProvider.modifierColor.baseColor,
                  fontColor: configDataProvider.modifierColor.fontColor,
                  fontSize: configDataProvider.size,
                ),
                SolidStyleKey(
                  width: configDataProvider.size * 4,
                  iconPath: configDataProvider.showIcon
                      ? "assets/symbols/shift.svg"
                      : null,
                  keyName: configDataProvider.showIcon ? "shift" : "Shift",
                  textAlignment: alignment,
                  baseColor: configDataProvider.modifierColor.baseColor,
                  fontColor: configDataProvider.modifierColor.fontColor,
                  fontSize: configDataProvider.size,
                ),
                SolidStyleKey(
                  keyName: "3",
                  symbol: configDataProvider.showSymbol ? "#" : null,
                  width: configDataProvider.size * 2.5,
                  baseColor: configDataProvider.keyColor.baseColor,
                  fontColor: configDataProvider.keyColor.fontColor,
                  fontSize: configDataProvider.size,
                ),
              ];

            case KeycapStyle.isometric:
              return [
                IsoStyleKey(
                  width: configDataProvider.size * 4,
                  iconPath: configDataProvider.showIcon
                      ? "assets/symbols/control.svg"
                      : null,
                  keyName: configDataProvider.showIcon ? "control" : "Ctrl",
                  textAlignment: alignment,
                  baseColor: configDataProvider.modifierColor.baseColor,
                  fontColor: configDataProvider.modifierColor.fontColor,
                  fontSize: configDataProvider.size,
                ),
                IsoStyleKey(
                  width: configDataProvider.size * 4,
                  iconPath: configDataProvider.showIcon
                      ? "assets/symbols/shift.svg"
                      : null,
                  keyName: configDataProvider.showIcon ? "shift" : "Shift",
                  textAlignment: alignment,
                  baseColor: configDataProvider.modifierColor.baseColor,
                  fontColor: configDataProvider.modifierColor.fontColor,
                  fontSize: configDataProvider.size,
                ),
                IsoStyleKey(
                  keyName: "3",
                  symbol: configDataProvider.showSymbol ? "#" : null,
                  width: configDataProvider.size * 2.5,
                  baseColor: configDataProvider.keyColor.baseColor,
                  fontColor: configDataProvider.keyColor.fontColor,
                  fontSize: configDataProvider.size,
                  textAlignment: Alignment.center,
                ),
              ];
          }
        }(),
      ),
    );
  }
}
