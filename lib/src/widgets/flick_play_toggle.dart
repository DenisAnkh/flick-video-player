import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Show a widget based on play/pause state of the player and toggle the same.
class FlickPlayToggle extends StatelessWidget {
  const FlickPlayToggle({
    Key? key,
    this.playChild,
    this.pauseChild,
    this.replayChild,
    this.bufferingChild,
    this.togglePlay,
    this.justRender = false,
    this.color,
    this.size,
    this.padding,
    this.decoration,
  }) : super(key: key);

  /// Widget shown when the video is paused.
  ///
  /// Default - Icon(Icons.play_arrow)
  final Widget? playChild;

  /// Widget shown when the video is playing.
  ///
  /// Default - Icon(Icons.pause)
  final Widget? pauseChild;

  /// Widget shown when the video is ended.
  ///
  /// Default - Icon(Icons.replay)
  final Widget? replayChild;

  /// Widget shown when the video is buffering.
  ///
  /// Default - SizedBox()
  final Widget? bufferingChild;

  /// Function called onTap of visible child.
  ///
  /// Default action -
  /// ``` dart
  ///     videoManager.isVideoEnded
  ///     ? controlManager.replay()
  ///     : controlManager.togglePlay();
  /// ```
  final Function? togglePlay;

  /// Size for the default icons.
  final double? size;

  /// Color for the default icons.
  final Color? color;

  /// Padding around the visible child.
  final EdgeInsetsGeometry? padding;

  /// Decoration around the visible child.
  final Decoration? decoration;

  /// If true then the widget just render self and won't supply any action (no GuestureDetector will be used).
  final bool justRender;

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    Widget playWidget = playChild ??
        Icon(
          Icons.play_arrow_rounded,
          size: size,
          color: color,
        );
    Widget pauseWidget = pauseChild ??
        Icon(
          Icons.pause_rounded,
          size: size,
          color: color,
        );
    Widget replayWidget = replayChild ??
        Icon(
          Icons.replay_rounded,
          size: size,
          color: color,
        );

    Widget bufferingWidget = bufferingChild ?? const SizedBox();

    Widget child = videoManager.isVideoEnded
        ? replayWidget
        : videoManager.isBuffering
            ? bufferingWidget
            : videoManager.isPlaying
                ? pauseWidget
                : playWidget;

    Widget widget = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (justRender) {
      return widget;
    }

    return GestureDetector(
        key: key,
        onTap: () {
          if (togglePlay != null) {
            togglePlay!();
          } else {
            videoManager.isVideoEnded
                ? controlManager.replay()
                : controlManager.togglePlay();
          }
        },
        child: widget);
  }
}
