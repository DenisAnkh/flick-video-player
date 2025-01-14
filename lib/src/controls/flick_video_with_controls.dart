import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

/// Default Video with Controls.
///
/// Returns a Stack with the following arrangement.
///    * [FlickVideoPlayer]
///    * Stack (Wrapped with [Positioned.fill()])
///      * Video Player loading fallback (conditionally rendered if player is not initialized).
///      * Video player error fallback (conditionally rendered if error in initializing the player).
///      * Controls.
class FlickVideoWithControls extends StatefulWidget {
  const FlickVideoWithControls({
    Key? key,
    this.controls,
    this.videoFit = BoxFit.cover,
    this.videoPlayerBuilder,
    this.videoPlayerWrapperBuilder,
    this.poster,
    this.playerLoadingFallback = const CircularProgressIndicator(),
    this.playerErrorFallback = const Center(
      child: const Icon(
        Icons.error,
        color: Colors.white,
      ),
    ),
    this.backgroundColor = Colors.black,
    this.iconThemeData = const IconThemeData(
      color: Colors.white,
      size: 20,
    ),
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
    this.aspectRatioWhenLoading = 16 / 9,
    this.willVideoPlayerControllerChange = true,
    this.closedCaptionTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
  }) : super(key: key);

  /// Create custom controls or use any of these [FlickPortraitControls], [FlickLandscapeControls]
  final Widget? controls;

  /// Widget (e.g. Image) that will be used as poster during video loading
  final Widget? poster;

  /// Conditionally rendered if player is not initialized.
  final Widget playerLoadingFallback;

  /// Conditionally rendered if player is has errors.
  final Widget playerErrorFallback;

  /// Property passed to [FlickVideoPlayer]
  final BoxFit videoFit;
  final Color backgroundColor;

  /// Used in [DefaultTextStyle]
  ///
  /// Use this property if you require to override the text style provided by the default Flick widgets.
  ///
  /// If any text style property is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final TextStyle textStyle;

  /// Used in [DefaultTextStyle]
  ///
  /// Use this property if you require to override the text style provided by the default ClosedCaption widgets.
  ///
  /// If any text style property is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final TextStyle closedCaptionTextStyle;

  /// Used in [IconTheme]
  ///
  /// Use this property if you require to override the icon style provided by the default Flick widgets.
  ///
  /// If any icon style is passed to Flick Widget at the time of widget creation, that style wont be overridden.
  final IconThemeData iconThemeData;

  /// If [FlickPlayer] has unbounded constraints this aspectRatio is used to take the size on the screen.
  ///
  /// Once the video is initialized, video determines size taken.
  final double aspectRatioWhenLoading;

  /// If false videoPlayerController will not be updated.
  final bool willVideoPlayerControllerChange;

  /// The builder must return [VideoPlayer] instance or wrapped with a container [VideoPlayer] instance.
  /// The builder may be usefull to apply some transformation to VideoPlayer (e.g., flipping or ratating).
  final VideoPlayerBuilder? videoPlayerBuilder;

  /// The builder must return [VideoPlayer] instance or wrapped with a container [VideoPlayer] instance.
  /// The builder may be usefull to apply some transformation to VideoPlayer (e.g., flipping or ratating).
  final VideoPlayerWrapperBuilder? videoPlayerWrapperBuilder;

  get videoPlayerController => null;

  @override
  _FlickVideoWithControlsState createState() => _FlickVideoWithControlsState();
}

class _FlickVideoWithControlsState extends State<FlickVideoWithControls> {
  VideoPlayerController? _videoPlayerController;
  @override
  void didChangeDependencies() {
    VideoPlayerController? newController =
        Provider.of<FlickVideoManager>(context).videoPlayerController;
    if ((widget.willVideoPlayerControllerChange &&
            _videoPlayerController != newController) ||
        _videoPlayerController == null) {
      _videoPlayerController = newController;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    bool _showVideoCaption = controlManager.isSub;
    return IconTheme(
      data: widget.iconThemeData,
      child: Container(
        color: widget.backgroundColor,
        child: DefaultTextStyle(
          style: widget.textStyle,
          child: Stack(
            children: <Widget>[
              Center(
                child: FlickNativeVideoPlayer(
                  videoPlayerController: _videoPlayerController,
                  fit: widget.videoFit,
                  aspectRatioWhenLoading: widget.aspectRatioWhenLoading,
                  videoPlayerBuilder: widget.videoPlayerBuilder,
                  videoPlayerWrapperBuilder: widget.videoPlayerWrapperBuilder,
                  poster: widget.poster,
                  // playerLoadingFallback: widget.playerLoadingFallback,
                ),
              ),
              Positioned.fill(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    _videoPlayerController!.closedCaptionFile != null &&
                            _showVideoCaption
                        ? Positioned(
                            bottom: 5,
                            child: Transform.scale(
                              scale: 0.7,
                              child: ClosedCaption(
                                  textStyle: widget.closedCaptionTextStyle,
                                  text: _videoPlayerController!
                                      .value.caption.text),
                            ),
                          )
                        : const SizedBox(),
                    if (_videoPlayerController?.value.hasError == false &&
                        (_videoPlayerController?.value.isInitialized == false ||
                            _videoPlayerController?.value.isBuffering == true))
                      Center(child: widget.playerLoadingFallback),
                    if (_videoPlayerController?.value.hasError == true)
                      Center(child: widget.playerErrorFallback),
                    widget.controls ?? const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
