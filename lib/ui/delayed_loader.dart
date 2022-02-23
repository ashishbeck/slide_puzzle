import 'package:flutter/material.dart';

import 'package:slide_puzzle/code/providers.dart';

class DelayedLoader extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final String label;
  final ConfigProvider configProvider;
  final bool preload;
  const DelayedLoader({
    Key? key,
    required this.child,
    required this.duration,
    required this.label,
    required this.configProvider,
    this.preload = false,
  }) : super(key: key);

  @override
  _DelayedLoaderState createState() => _DelayedLoaderState();
}

class _DelayedLoaderState extends State<DelayedLoader> {
  bool _ifAnimated() {
    String name = widget.label;
    if (widget.configProvider.entryAnimationDone[name] != null &&
        widget.configProvider.entryAnimationDone[name]!) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return _ifAnimated()
        ? widget.child
        : FutureBuilder(
            future: Future.delayed(widget.duration),
            builder: (context, snapshot) {
              bool isDone = snapshot.connectionState == ConnectionState.done;
              if (isDone) {
                widget.configProvider.seenEntryAnimation(widget.label);
              }
              return widget.preload
                  ? Opacity(
                      opacity: isDone ? 1 : 0.01,
                      child: widget.child,
                    )
                  : isDone
                      ? widget.child
                      : Container();
            });
  }
}
