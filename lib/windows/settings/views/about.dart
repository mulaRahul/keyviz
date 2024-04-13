import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/shared.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              height: 200,
              width: 180,
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: defaultBorderRadius,
                border: Border.all(color: context.colorScheme.outline),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/img/logo.svg",
                    height: defaultPadding * 3.5,
                  ),
                  const SmallColumnGap(),
                  Text(
                    "Keyviz 2.0.0-alpha2",
                    style: context.textTheme.titleSmall,
                  ),
                  Text(
                    "by Rahul Mula",
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SmallRowGap(),
            Expanded(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: defaultBorderRadius,
                  border: Border.all(color: context.colorScheme.outline),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: SvgPicture.asset(
                        "assets/img/keycap-grid.svg",
                        width: defaultPadding * 9,
                        height: defaultPadding * 9,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(
                        defaultPadding * 1.5,
                      ).copyWith(right: defaultPadding * 4),
                      child: Text(
                        "This is an alpha release, so bugs 🐛 are expected. "
                        "If you find any bugs report the same!",
                        style: context.textTheme.labelSmall?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Positioned(
                    //   left: defaultPadding * 1.5,
                    //   bottom: defaultPadding * 1.5,
                    //   child: RichText(
                    //     text: const TextSpan(
                    //       children: [
                    //         TextSpan(
                    //           text: "⌨️",
                    //           style: TextStyle(fontSize: 40),
                    //         ),
                    //         TextSpan(
                    //           text: "🖱️",
                    //           style: TextStyle(fontSize: 30),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Positioned(
                      left: defaultPadding * 1.5,
                      bottom: defaultPadding * 1.5,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => launchUrlString(
                              "https://discord.gg/qyrKWCvtEq",
                            ),
                            tooltip: "Discord",
                            icon: const SvgIcon(
                              icon: "assets/img/discord-logo.svg",
                              size: defaultPadding * .8,
                            ),
                          ),
                          IconButton(
                            onPressed: () => launchUrl(
                              Uri.parse("mailto:rahulmula10@gmail.com"),
                            ),
                            tooltip: "Email",
                            icon: const SvgIcon(icon: VuesaxIcons.mail),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        const SmallColumnGap(),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: defaultBorderRadius,
                  border: Border.all(color: context.colorScheme.outline),
                ),
                padding: const EdgeInsets.all(defaultPadding * 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "💻 From Dev",
                      style: context.textTheme.titleLarge,
                    ),
                    const VerySmallColumnGap(),
                    Text(
                      "Hi 👋, I'm Rahul Mula, the developer of Keyviz. "
                      "I'm an instructor, and I teach courses online. \n\n"
                      "When recording my screen, I've always felt the need "
                      "to show my keystrokes to the audience. That's when I "
                      "decided to develop keyviz, and share it with others "
                      "to help people like me.",
                      style: context.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SmallRowGap(),
            Container(
              height: 250,
              width: 200,
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: defaultBorderRadius,
                border: Border.all(color: context.colorScheme.outline),
              ),
              padding: const EdgeInsets.all(defaultPadding * 1.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "💖 Support",
                    style: context.textTheme.titleLarge,
                  ),
                  const VerySmallColumnGap(),
                  Text(
                    "As keyviz is freeware, the only way I can earn is "
                    "through your generous donations. It helps free my time "
                    "and work more on keyviz.",
                    style: context.textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => launchUrlString(
                          "https://github.com/sponsors/mulaRahul",
                        ),
                        tooltip: "Github Sponsors",
                        icon: const SvgIcon(icon: "assets/img/github-logo.svg"),
                      ),
                      IconButton(
                        onPressed: () => launchUrlString(
                          "https://opencollective.com/keyviz",
                        ),
                        tooltip: "Open Collective",
                        icon: SvgPicture.asset(
                          "assets/img/opencollective-logo.svg",
                          width: defaultPadding,
                          height: defaultPadding,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
