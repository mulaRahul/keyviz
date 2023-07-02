import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/providers/providers.dart';

import 'widgets/widgets.dart';

// positions key visualizer
class KeyVisualizer extends StatelessWidget {
  const KeyVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<KeyStyleProvider, Tuple2<Alignment, double>>(
      builder: (context, tuple, child) => Align(
        alignment: tuple.item1,
        child: Padding(
          padding: _padding(tuple.item1, tuple.item2),
          child: child!,
        ),
      ),
      selector: (_, keyStyle) => Tuple2(keyStyle.alignment, keyStyle.margin),
      child: const _KeyVisualizer(),
    );
  }

  EdgeInsets _padding(Alignment alignment, double value) {
    final padding = EdgeInsets.all(value);
    switch (alignment) {
      case Alignment.bottomRight:
      case Alignment.bottomCenter:
      case Alignment.bottomLeft:
        return padding.copyWith(top: 0);

      case Alignment.centerRight:
      case Alignment.center:
      case Alignment.centerLeft:
        return padding.copyWith(top: 0, bottom: 0);

      case Alignment.topRight:
      case Alignment.topCenter:
      case Alignment.topLeft:
        return padding.copyWith(bottom: 0);
    }
    return padding;
  }
}

// maps events to KeyCapGroup or VisualizationHistory
class _KeyVisualizer extends StatelessWidget {
  const _KeyVisualizer();

  @override
  Widget build(BuildContext context) {
    // visualization history mode
    final historyDirection = context.select<KeyEventProvider, Axis?>(
      (keyEvent) => keyEvent.historyDirection,
    );
    return Selector<KeyEventProvider, Map<String, Map<int, KeyEventData>>>(
      builder: (context, events, _) {
        // ignoring history
        if (historyDirection == null) {
          if (events.isEmpty) {
            // placeholder
            return const SizedBox();
          } else {
            // single display list
            final groupId = events.keys.last;

            return KeyCapGroup(
              groupId: groupId,
              events: events[groupId]!,
            );
          }
        }
        // showing history
        else {
          return _VisualizationHistory(
            events: events,
            direction: historyDirection,
          );
        }
      },
      selector: (_, keyEvent) => keyEvent.keyboardEvents,
      shouldRebuild: (previous, next) => mapEquals(previous, next),
    );
  }
}

class _VisualizationHistory extends StatelessWidget {
  const _VisualizationHistory({required this.events, required this.direction});

  final Axis direction;
  final Map<String, Map<int, KeyEventData>> events;

  @override
  Widget build(BuildContext context) {
    return Selector<KeyStyleProvider, Tuple2<Alignment, double>>(
      builder: (context, tuple, child) => Wrap(
        direction: direction,
        spacing: tuple.item2,
        runSpacing: tuple.item2,
        alignment: _wrapAlignment(tuple.item1),
        crossAxisAlignment: _crossAxisAlignment(tuple.item1),
        children: [
          for (final groupId in _showReversed(tuple.item1)
              ? events.keys.toList().reversed
              : events.keys)
            // sanity check
            if (events[groupId] != null)
              KeyCapGroup(groupId: groupId, events: events[groupId]!)
        ],
      ),
      selector: (_, keyStyle) => Tuple2(
        keyStyle.alignment,
        keyStyle.backgroundSpacing,
      ),
    );
  }

  bool _showReversed(Alignment alignment) {
    return alignment == Alignment.topLeft ||
        alignment == Alignment.topCenter ||
        alignment == Alignment.topRight;
  }

  WrapAlignment _wrapAlignment(Alignment alignment) {
    // showing history vertically
    if (direction == Axis.vertical) return WrapAlignment.start;

    switch (alignment) {
      case Alignment.topLeft:
      case Alignment.centerLeft:
      case Alignment.bottomLeft:
        return WrapAlignment.start;

      case Alignment.topCenter:
      case Alignment.center:
      case Alignment.bottomCenter:
        return WrapAlignment.center;

      case Alignment.topRight:
      case Alignment.centerRight:
      case Alignment.bottomRight:
        return WrapAlignment.end;
    }

    return WrapAlignment.start;
  }

  WrapCrossAlignment _crossAxisAlignment(Alignment alignment) {
    // showing history horizontally
    if (direction == Axis.horizontal) return WrapCrossAlignment.start;

    switch (alignment) {
      case Alignment.topLeft:
      case Alignment.centerLeft:
      case Alignment.bottomLeft:
        return WrapCrossAlignment.start;

      case Alignment.topCenter:
      case Alignment.center:
      case Alignment.bottomCenter:
        return WrapCrossAlignment.center;

      case Alignment.topRight:
      case Alignment.centerRight:
      case Alignment.bottomRight:
        return WrapCrossAlignment.end;
    }

    return WrapCrossAlignment.start;
  }
}
