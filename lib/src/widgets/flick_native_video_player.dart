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
    this.playerLoadingFallback,
  }) : super(key: key);

  final BoxFit? fit;
  final double? aspectRatioWhenLoading;
  final VideoPlayerController? videoPlayerController;
  final Widget? poster;
  final Widget? playerLoadingFallback;

  /// The builder must return [VideoPlayer] instance or [VideoPlayer] wrapped with a container.
  /// The builder may be usefull to apply some transformation to VideoPlayer (e.g., flipping or ratating).
  final VideoPlayerBuilder? videoPlayerBuilder;

  /// The builder must return prepared [FlickNativeVideoPlayer] inner content or the content wrapped with a container.
  /// The builder may be usefull to apply complete transformation to already ready VideoPlayer (e.g., adding watermark or extra nav or bottom shadow effects).
  final VideoPlayerWrapperBuilder? videoPlayerWrapperBuilder;

  @override
  Widget build(BuildContext context) {
    // double? videoHeight = videoPlayerController?.value.size.height;
    // double? videoWidth = videoPlayerController?.value.size.width;

    return LayoutBuilder(
      key: ValueKey(hashCode),
      builder: (context, size) {
        bool isInitialized = videoPlayerController?.value.isInitialized == true;

        double? videoAspectRatio = isInitialized
            ? videoPlayerController?.value.aspectRatio
            : aspectRatioWhenLoading;

        double viewportAspectRatio = size.maxWidth / size.maxHeight;

        double resultAspectRatio = videoAspectRatio == null
            ? viewportAspectRatio
            : videoAspectRatio / viewportAspectRatio;

        bool isStarted = isInitialized &&
            videoPlayerController!.value.position.inMicroseconds > 0;

        late Widget videoPlayer;

        // if (isStarted) {
        if (isInitialized) {
          // debugPrint(
          //     'VVVV222: ${videoPlayerController?.value.isInitialized}, ${videoPlayerController!.value.position.inMicroseconds}');
          videoPlayer = Container(
            // height: videoHeight,
            // width: videoWidth,
            height: size.maxHeight,
            width: size.maxWidth,
            child: VideoPlayer(videoPlayerController!),
          );
        } else {
          // debugPrint(
          //     'VVVV111: ${videoPlayerController?.value.isInitialized}, ${videoPlayerController!.value.position.inMicroseconds}');
          videoPlayer = Container(
            height: size.maxHeight,
            width: size.maxWidth,
          );
        }

        if (videoPlayerBuilder != null) {
          videoPlayer = videoPlayerBuilder!(videoPlayer, videoPlayerController);
        }

        Widget preparedVideoPlayer = SizedBox(
          height: size.maxHeight,
          width: size.maxWidth,
          child: FittedBox(
              fit: fit!,
              alignment: Alignment.topCenter,
              child: SizedBox(
                  height: size.maxHeight,
                  width: size.maxWidth * resultAspectRatio,
                  child: videoPlayer)),
        );

        if (poster != null) {
          preparedVideoPlayer = Container(
            color: Theme.of(context).colorScheme.surface,
            height: size.maxHeight,
            width: size.maxWidth,
            child: Stack(
              children: [
                Positioned.fill(child: poster!),
                if (isStarted) preparedVideoPlayer,
                // if (!isStarted && playerLoadingFallback != null)
                //   playerLoadingFallback!,
              ],
            ),
          );
        } else {
          preparedVideoPlayer = Container(
            color: Theme.of(context).colorScheme.surface,
            height: size.maxHeight,
            width: size.maxWidth,
            child: preparedVideoPlayer,
          );
        }

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
