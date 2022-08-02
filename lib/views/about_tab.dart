import 'package:flutter/material.dart';
import 'package:keyviz/widgets/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/properties.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(56),
      child: Column(
        children: [
          Image.asset("assets/img/icon.png"),
          const Space(),
          const Text("Keyviz v1.0.0", style: paragraphStyle),
          const Text("©️ Rahul Mula", style: paragraphStyle),
          const SizedBox(height: 32),
          const Text(
            "If you find any issue/bug or have any suggestion/feature-requests, please contact with the below links.",
            style: paragraphStyle,
            textAlign: TextAlign.center,
          ),
          const Space(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => launchUrl(
                  Uri.parse("https://discord.gg/qyrKWCvtEq"),
                ),
                style: elevatedButtonStyle,
                child: const Text("Discord"),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: () => launchUrl(
                  Uri.parse("mailto:rahulmula10@gmail.com"),
                ),
                style: elevatedButtonStyle,
                child: const Text("rahulmula10@gmail.com"),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "Keyviz is free and open-source software and if it provides value to you, then that's all that matters ✨. If you'd like to donate/sponsor the project then you're most welcome 💖!\nIt doesn't matter how much you donate, it's your initiative that brings a smile to my face 😁. Either you donate, sponsor, or just drop in to say thanks - it reminds me of the fact that it's not my fun project anymore, it's our project!",
            style: paragraphStyle,
            textAlign: TextAlign.center,
          ),
          const Space(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => launchUrl(
                  Uri.parse("https://www.paypal.com/paypalme/ral162"),
                ),
                style: elevatedButtonStyle,
                child: const Text("PayPal"),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: () => launchUrl(
                  Uri.parse("https://github.com/sponsors/mulaRahul/"),
                ),
                style: elevatedButtonStyle,
                child: const Text("Github Sponsor"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
