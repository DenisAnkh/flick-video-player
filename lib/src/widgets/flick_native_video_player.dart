import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Signature for a function that creates a native video player widget.
/// The builder must return [VideoPlayer] instance or wrapped with a container [VideoPlayer] instance.
/// The builder may be usefull to apply some transformation to VideoPlayer (e.g., flipping or ratating).
///
/// Used by [FlickNativeVideoPlayer]
///
typedef VideoPlayerWidgetBuilder = Widget Function(
    BuildContext context, VideoPlayerController? videoPlayerController);

/// Renders [VideoPlayer] with [BoxFit] configurations.
class FlickNativeVideoPlayer extends StatelessWidget {
  const FlickNativeVideoPlayer(
      {Key? key,
      this.fit,
      this.aspectRatioWhenLoading,
      required this.videoPlayerController,
      this.videoPlayerBuilder})
      : super(key: key);

  final BoxFit? fit;
  final double? aspectRatioWhenLoading;
  final VideoPlayerController? videoPlayerController;

  /// The builder must return [VideoPlayer] instance or wrapped with a container [VideoPlayer] instance.
  /// The builder may be usefull to apply some transformation to VideoPlayer (e.g., flipping or ratating).
  final VideoPlayerWidgetBuilder? videoPlayerBuilder;

  @override
  Widget build(BuildContext context) {
    Widget videoPlayer;
    if (videoPlayerBuilder == null) {
      videoPlayer = VideoPlayer(videoPlayerController!);
    } else {
      videoPlayer = videoPlayerBuilder!(context, videoPlayerController);
    }

    double? videoHeight = videoPlayerController?.value.size.height;
    double? videoWidth = videoPlayerController?.value.size.width;

    return LayoutBuilder(
      builder: (context, size) {
        double aspectRatio = (size.maxHeight == double.infinity ||
                size.maxWidth == double.infinity)
            ? (videoPlayerController?.value.isInitialized == true
                ? videoPlayerController?.value.aspectRatio
                : aspectRatioWhenLoading!)!
            : size.maxWidth / size.maxHeight;

        return AspectRatio(
          aspectRatio: aspectRatio,
          child: FittedBox(
            fit: fit!,
            child: videoPlayerController?.value.isInitialized == true
                ? Container(
                    height: videoHeight,
                    width: videoWidth,
                    child: videoPlayer,
                  )
                : Container(),
          ),
        );
      },
    );
  }
}
