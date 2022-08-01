import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:window_manager/window_manager.dart';

import '../data/config.dart';
import '../data/properties.dart';
import 'about_tab.dart';
import 'general_tab.dart';
import 'keycap_styler.dart';
import 'keycapture.dart';
import 'style_tab.dart';
import 'appearance_tab.dart';

class SettingsView extends StatefulWidget {
  final Function exitSettings;

  const SettingsView({
    Key? key,
    required this.exitSettings,
  }) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String currentTab = "style";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          GestureDetector(
            onPanStart: (details) => windowManager.startDragging(),
            child: Container(
              color: lightGrey,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  TabItem(
                    label: 'General',
                    iconPath: "assets/img/setting.svg",
                    onTap: () => setTab('general'),
                    selected: currentTab == 'general',
                  ),
                  const SizedBox(width: 8),
                  TabItem(
                    label: 'Style',
                    iconPath: "assets/img/magicpen.svg",
                    selected: currentTab == 'style',
                    onTap: () => setTab("style"),
                  ),
                  const SizedBox(width: 8),
                  TabItem(
                    label: 'Appearance',
                    iconPath: "assets/img/monitor.svg",
                    selected: currentTab == 'appearance',
                    onTap: () => setTab('appearance'),
                  ),
                  const SizedBox(width: 8),
                  TabItem(
                    label: 'About',
                    iconPath: "assets/img/info.svg",
                    selected: currentTab == 'about',
                    onTap: () => setTab('about'),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content:
                                const Text("Do you want to save the changes?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();

                                  configData.configuring = false;
                                  configData.saveToPrefs();

                                  widget.exitSettings();
                                },
                                child: const Text("Save"),
                              ),
                            ],
                          );
                        }),
                    child: SvgPicture.asset(
                      "assets/img/cross.svg",
                      color: darkGrey,
                      width: 12,
                    ),
                  )
                ],
              ),
            ),
          ),
          currentTab == "about"
              ? const SizedBox()
              : Container(
                  height: 64 * 5, // 64*5
                  alignment: Alignment.center,
                  child: currentTab == 'style'
                      ? const KeycapStyler()
                      : const KeycaptureView(noPadding: true),
                ),
          Expanded(
            child: Container(
              // height: 394,
              color: currentTab == "about" ? grey : lightGrey,
              child: SingleChildScrollView(
                child: () {
                  switch (currentTab) {
                    case "general":
                      return const GeneralTab();

                    case "style":
                      return const StyleTab();

                    case "appearance":
                      return const AppearanceTab();

                    case "about":
                      return const AboutTab();
                  }
                }(),
              ),
            ),
          )
        ],
      ),
    );
  }

  setTab(String tabName) => setState(() => currentTab = tabName);
}

class TabItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool selected;
  final Function onTap;

  const TabItem({
    Key? key,
    required this.label,
    required this.iconPath,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: AnimatedContainer(
        duration: configData.transitionDuration,
        curve: Curves.easeOutExpo,
        width: 90,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? darkerGrey : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              iconPath,
              color: selected ? Colors.white : darkerGrey,
            ),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                label,
                style: TextStyle(color: selected ? Colors.white : darkerGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
