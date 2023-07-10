import 'package:flutter/material.dart';
import 'package:keyviz/windows/shared/shared.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_event.dart';
import 'package:window_manager/window_manager.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<KeyEventProvider, List<String>>(
      selector: (_, keyEvent) => keyEvent.errors,
      builder: (context, errors, __) => errors.isEmpty
          ? const SizedBox()
          : Center(
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  border: Border.all(color: context.colorScheme.error),
                  borderRadius: BorderRadius.circular(defaultPadding),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: windowManager.close,
                        tooltip: "Quit App",
                        icon: SvgIcon.cross(
                          size: defaultPadding * .6,
                          color: context.colorScheme.error,
                        ),
                      ),
                    ),
                    SvgIcon(
                      size: defaultPadding * 3,
                      color: context.colorScheme.error,
                      icon: VuesaxIcons.error,
                    ),
                    const ColumnGap(),
                    Text(
                      errors.length == 1
                          ? "Cannot register ${errors.first} listener!"
                          : "Cannot register keyboard & mouse listener!",
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                    const SmallColumnGap(),
                  ],
                ),
              ),
            ),
    );
  }
}
