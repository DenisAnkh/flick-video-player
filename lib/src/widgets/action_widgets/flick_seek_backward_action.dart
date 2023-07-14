import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Show a widget based on the mute/unmute state of the player and toggle the same.
class FlickSeekBackwardAction extends StatelessWidget {
  const FlickSeekBackwardAction({
    Key? key,
    this.duration = const Duration(seconds: 10),
    this.size,
    this.color,
    this.padding,
    this.decoration,
  }) : super(key: key);

  final Duration duration;

  /// Size for the default icons.
  final double? size;

  /// Color for the default icons.
  final Color? color;

  /// Padding around the visible child.
  final EdgeInsetsGeometry? padding;

  /// Decoration around the visible child.
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);

    Widget child = switch (duration.inSeconds) {
      5 => Icon(
          Icons.replay_5_rounded,
          size: size,
          color: color,
        ),
      10 => Icon(
          Icons.replay_10_rounded,
          size: size,
          color: color,
        ),
      30 => Icon(
          Icons.replay_30_rounded,
          size: size,
          color: color,
        ),
      _ => Icon(
          Icons.replay,
          size: size,
          color: color,
        )
    };

    return GestureDetector(
        key: key,
        onTap: () {
          controlManager.seekBackward(Duration(seconds: 10));
        },
        child: Container(
          padding: padding,
          decoration: decoration,
          child: child,
        ));
  }
}
