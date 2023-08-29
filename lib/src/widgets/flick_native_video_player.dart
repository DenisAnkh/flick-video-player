import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Signature for a function that creates a native video player widget.
/// The builder must return [VideoPlayer] instance or wrapped with a container [VideoPlayer] instance.
/// The builder may be usefull to apply some transformation to VideoPlayer (e.g., flipping or ratating).
///
/// Used by [FlickNativeVideoPlayer]
///
typedef VideoPlayerBuilder = Widget Function(
    Widget rawVideoPlayer, VideoPlayerController? videoPlayerController);

/// Signature for a function that creates a wrapper for native video player widget.
/// The builder must return prepared [FlickNativeVideoPlayer] inner content or the content wrapped with a container.
/// The builder may be usefull to apply complete transformation to already ready VideoPlayer (e.g., adding watermark or extra nav or bottom shadow effects).
///
/// Used by [FlickNativeVideoPlayer]
///
typedef VideoPlayerWrapperBuilder = Widget Function(
    Widget preparedVideoPlayer, VideoPlayerController? videoPlayerController);

/// Renders [VideoPlayer] with [BoxFit] configurations.
class FlickNativeVideoPlayer extends StatelessWidget {
  const FlickNativeVideoPlayer({
    Key? key,
    this.fit,
    this.aspectRatioWhenLoading,
    required this.videoPlayerController,
    this.videoPlayerBuilder,
    this.videoPlayerWrapperBuilder,
    this.poster,
  }) : super(key: key);

  final BoxFit? fit;
  final double? aspectRatioWhenLoading;
  final VideoPlayerController? videoPlayerController;
  final Widget? poster;

  /// The builder must return [VideoPlayer] instance or [VideoPlayer] wrapped with a container.
  /// The builder may be usefull to apply some transformation to VideoPlayer (e.g., flipping or ratating).
  final VideoPlayerBuilder? videoPlayerBuilder;

  /// The builder must return prepared [FlickNativeVideoPlayer] inner content or the content wrapped with a container.
  /// The builder may be usefull to apply complete transformation to already ready VideoPlayer (e.g., adding watermark or extra nav or bottom shadow effects).
  final VideoPlayerWrapperBuilder? videoPlayerWrapperBuilder;

  @override
  Widget build(BuildContext context) {
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

        bool videoInitialized =
            videoPlayerController?.value.isInitialized == true;

        late Widget videoPlayer;

        if (poster != null) {
          if (videoInitialized) {
            videoPlayer = Container(
              height: videoHeight,
              width: videoWidth,
              child: Stack(
                children: [
                  Positioned.fill(child: poster!),
                  VideoPlayer(videoPlayerController!),
                ],
              ),
            );
          } else {
            videoPlayer = Container(
              height: size.maxHeight,
              width: size.maxWidth,
              child: Stack(
                children: [
                  Positioned.fill(child: poster!),
                ],
              ),
            );
          }
        } else {
          if (videoInitialized) {
            videoPlayer = Container(
              height: videoHeight,
              width: videoWidth,
              child: VideoPlayer(videoPlayerController!),
            );
          } else {
            videoPlayer = Container(
              height: size.maxHeight,
              width: size.maxWidth,
            );
          }
        }

        if (videoPlayerBuilder != null) {
          videoPlayer = videoPlayerBuilder!(videoPlayer, videoPlayerController);
        }

        final preparedVideoPlayer = AspectRatio(
          aspectRatio: aspectRatio,
          child: FittedBox(
            fit: fit!,
            child: videoPlayer,
          ),
        );

        if (videoPlayerWrapperBuilder == null) {
          return preparedVideoPlayer;
        } else {
          return videoPlayerWrapperBuilder!(
              preparedVideoPlayer, videoPlayerController);
        }
      },
    );
  }
}
