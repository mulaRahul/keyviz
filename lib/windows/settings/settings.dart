import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/domain/vault/vault.dart';
import 'package:keyviz/providers/key_event.dart';
import 'package:keyviz/windows/shared/shared.dart';

import 'views/views.dart';
import 'widgets/widgets.dart';

class SettingsWindow extends StatelessWidget {
  const SettingsWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<KeyEventProvider, bool>(
      selector: (_, keyEvent) => keyEvent.styling,
      builder: (_, show, __) {
        return show ? const _SettingsWindow() : const SizedBox();
      },
    );
  }
}

class _SettingsWindow extends StatefulWidget {
  const _SettingsWindow();

  @override
  State<_SettingsWindow> createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<_SettingsWindow> {
  SettingsTab _currentTab = SettingsTab.about;
  late final _positionNotifier = ValueNotifier<Offset>(const Offset(340, 260));

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: _positionNotifier,
      builder: (context, value, child) {
        return Positioned(
          top: value.dy,
          left: value.dx,
          child: child!,
        );
      },
      child: Container(
        width: 600,
        height: 560,
        padding: const EdgeInsets.all(defaultPadding).copyWith(
          top: defaultPadding * .5,
        ),
        decoration: _backgroundDecor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TopBar(
              onPanUpdate: _onPanUpdate,
            ),
            const VerySmallColumnGap(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SideBar(
                    currentTab: _currentTab,
                    onChange: (tab) => setState(() => _currentTab = tab),
                  ),
                  const SmallRowGap(),
                  Expanded(
                    child: DecoratedBox(
                      decoration: _innerDecor,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(defaultPadding * 1.5),
                        child: _currentTabView,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _currentTabView {
    switch (_currentTab) {
      case SettingsTab.general:
        return const GeneralTabView();

      case SettingsTab.mouse:
        return const MouseTabView();

      case SettingsTab.keycap:
        return const StyleTabView();

      case SettingsTab.appearance:
        return const AppearanceTabView();

      case SettingsTab.about:
        return const AboutView();
    }
  }

  BoxDecoration get _backgroundDecor => BoxDecoration(
        color: context.colorScheme.background,
        borderRadius: defaultBorderRadius,
        border: Border.all(
          color: context.theme.brightness == Brightness.dark
              ? context.colorScheme.onSecondary
              : context.colorScheme.outline,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, defaultPadding),
            blurRadius: defaultPadding * 2,
          )
        ],
      );

  BoxDecoration get _innerDecor => BoxDecoration(
        color: context.colorScheme.secondaryContainer,
        borderRadius: defaultBorderRadius,
      );

  _onPanUpdate(DragUpdateDetails details) {
    _positionNotifier.value = Offset(
      _positionNotifier.value.dx + details.delta.dx,
      _positionNotifier.value.dy + details.delta.dy,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onPanUpdate});

  final ValueChanged<DragUpdateDetails> onPanUpdate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: onPanUpdate,
          child: SizedBox(
            width: 80,
            height: 8,
            child: Center(
              child: SizedBox(
                width: 80,
                height: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withOpacity(.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            context.keyEvent.styling = false;
            Vault.save(context);
          },
          child: SvgIcon(
            icon: VuesaxIcons.cross,
            size: defaultPadding * .5,
            color: context.colorScheme.primary.withOpacity(.4),
          ),
        ),
      ],
    );
  }
}
