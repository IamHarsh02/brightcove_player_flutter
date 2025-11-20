import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class BrightcovePlayerWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final VoidCallback? onVideoEnd;
  final VoidCallback? onVideoStart;
  final VoidCallback? onVideoPause;
  final VoidCallback? onVideoPlay;
  final String? accountId;
  final String? policyKey;
  final String? videoId;

  const BrightcovePlayerWidget({
    Key? key,
    this.width,
    this.height,
    this.onVideoEnd,
    this.onVideoStart,
    this.onVideoPause,
    this.onVideoPlay,
    this.accountId,
    this.policyKey,
    this.videoId,
  }) : super(key: key);

  @override
  State<BrightcovePlayerWidget> createState() => BrightcovePlayerWidgetState();
}

class BrightcovePlayerWidgetState extends State<BrightcovePlayerWidget> {
  static const MethodChannel _channel = MethodChannel('com.example.addToApp');
  int? _platformViewId;

  // Progress tracking
  Duration _videoDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  Timer? _progressTimer;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
  }

  @override
  void dispose() {
    // Clean up method channel handler
    _channel.setMethodCallHandler(null);
    // Clean up progress timer
    _stopProgressTimer();
    super.dispose();
  }

  void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      debugPrint('Brightcove method call received: ${call.method}');
      switch (call.method) {
        case 'onVideoEnd':
          debugPrint('Brightcove onVideoEnd triggered');
          widget.onVideoEnd?.call();
          break;
        case 'onVideoStart':
          debugPrint('Brightcove onVideoStart triggered');
          widget.onVideoStart?.call();
          break;
        case 'onVideoPause':
          debugPrint('Brightcove onVideoPause triggered');
          widget.onVideoPause?.call();
          break;
        case 'onVideoPlay':
          debugPrint('Brightcove onVideoPlay triggered');
          widget.onVideoPlay?.call();
          break;
        case 'onVideoError':
          debugPrint('Brightcove video error: ${call.arguments}');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _buildAndroidView();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _buildIOSView();
    } else {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: const Center(
          child: Text(
            'Brightcove player not supported on this platform',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildAndroidView() {
    return AndroidView(
      viewType: 'brightcove-player',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: <String, dynamic>{
        'accountId': widget.accountId ?? '',
        'policyKey':
        widget.policyKey ??
            'BCpkADawqM3DwCTPGyMMiG0loem8lXox3utO1lFEP1i-_l1MpjRSVXMTSsa2ToslC129_W6YzwJpXbpbIVRFwf35qYM0pxo2HJK-_SotgmgrkmJTQ-024GkXIelVSY8LOHZzRBtcBU57M6Is',
        'videoId': widget.videoId ?? '',
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  Widget _buildIOSView() {
    return UiKitView(
      viewType: 'brightcove_player',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: <String, dynamic>{
        'accountId': widget.accountId ?? '',
        'policyKey':
        widget.policyKey ??
            'BCpkADawqM3DwCTPGyMMiG0loem8lXox3utO1lFEP1i-_l1MpjRSVXMTSsa2ToslC129_W6YzwJpXbpbIVRFwf35qYM0pxo2HJK-_SotgmgrkmJTQ-024GkXIelVSY8LOHZzRBtcBU57M6Is',
        'videoId': widget.videoId ?? '',
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  void _onPlatformViewCreated(int id) {
    _platformViewId = id;
    debugPrint('Brightcove platform view created with id: $id');
    _setupVideoReadyListener();
  }

  // Control methods that can be called from Flutter
  Future<void> play() async {
    debugPrint('Brightcove play() called - viewId: $_platformViewId');
    if (_platformViewId == null) {
      debugPrint('Platform view ID not available');
      return;
    }

    try {
      await _channel.invokeMethod('playVideo', {'viewId': _platformViewId});
      debugPrint('Play command sent successfully to viewId: $_platformViewId');
    } catch (e) {
      debugPrint('Error playing video: $e');
    }
  }

  Future<void> pause() async {
    debugPrint('Brightcove pause() called - viewId: $_platformViewId');
    if (_platformViewId == null) {
      debugPrint('Platform view ID not available');
      return;
    }

    try {
      await _channel.invokeMethod('pauseVideo', {'viewId': _platformViewId});
      debugPrint('Pause command sent successfully to viewId: $_platformViewId');
    } catch (e) {
      debugPrint('Error pausing video: $e');
    }
  }

  /// Seeks the Brightcove player to a specific position
  ///
  /// Native Implementation Required:
  /// Android: Add this to your MethodChannel handler:
  /// ```kotlin
  /// "seekToPosition" -> {
  ///   val viewId = call.argument<Int>("viewId") ?: return
  ///   val positionMs = call.argument<Int>("positionMs") ?: return
  ///   // Get your Brightcove player instance and call:
  ///   brightcovePlayer.seekTo(positionMs.toLong())
  ///   result.success(null)
  /// }
  /// ```
  Future<void> seekTo(Duration position) async {
    debugPrint(
      'Brightcove seekTo() called - position: ${position.inSeconds}s, viewId: $_platformViewId',
    );
    if (_platformViewId == null) {
      debugPrint('Platform view ID not available for seek');
      return;
    }

    try {
      await _channel.invokeMethod('seekToPosition', {
        'viewId': _platformViewId,
        'positionMs': position.inMilliseconds,
      });
      debugPrint(
        'Seek command sent successfully to viewId: $_platformViewId - position: ${position.inSeconds}s',
      );

      // Update current position immediately for responsive UI
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      if (e.toString().contains('MissingPluginException')) {
        debugPrint('⚠️ Brightcove seek not implemented in native code yet');
        debugPrint(
          '📋 Please implement seekToPosition method in native Android/iOS code',
        );

        // Still update the UI position for visual feedback
        setState(() {
          _currentPosition = position;
        });
      } else {
        debugPrint('Error seeking video: $e');
      }
    }
  }

  Future<Duration> getVideoDuration() async {
    if (_platformViewId == null) {
      debugPrint('Platform view ID not available');
      return Duration.zero;
    }

    try {
      final int durationMs = await _channel.invokeMethod('getVideoDuration', {
        'viewId': _platformViewId,
      });
      return Duration(milliseconds: durationMs);
    } catch (e) {
      debugPrint('Error getting video duration: $e');
      return Duration.zero;
    }
  }

  Future<Duration> getCurrentPosition() async {
    if (_platformViewId == null) {
      debugPrint('Platform view ID not available');
      return Duration.zero;
    }

    try {
      final int positionMs = await _channel.invokeMethod('getCurrentPosition', {
        'viewId': _platformViewId,
      });
      return Duration(milliseconds: positionMs);
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return Duration.zero;
    }
  }

  Future<bool> isVideoReady() async {
    if (_platformViewId == null) {
      debugPrint('Platform view ID not available');
      return false;
    }

    try {
      final bool isReady = await _channel.invokeMethod('checkVideoReady', {
        'viewId': _platformViewId,
      });
      return isReady;
    } catch (e) {
      debugPrint('Error checking if video is ready: $e');
      return false;
    }
  }

  // Progress tracking methods
  void _setupVideoReadyListener() {
    debugPrint('🎬 Setting up video ready listener');

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        if (_platformViewId != null) {
          try {
            final bool isReady = await isVideoReady();
            if (isReady && !_isVideoReady) {
              debugPrint('🎬 iOS Video is ready! Loading duration...');
              _isVideoReady = true;
              _loadVideoDuration();
              timer.cancel();
            }
          } catch (e) {
            debugPrint('Error checking iOS video ready: $e');
          }
        }

        if (timer.tick >= 20) {
          debugPrint('⏰ iOS Video ready check timeout - stopping listener');
          timer.cancel();
        }
      });
    } else {
      debugPrint('🤖 Android platform detected - using delayed approach');
      Future.delayed(const Duration(milliseconds: 1000), () {
        _loadVideoDuration();
      });
    }
  }

  void _loadVideoDuration() async {
    if (_platformViewId != null) {
      try {
        debugPrint('🔄 Starting to load Brightcove video duration...');
        final duration = await getVideoDuration();
        debugPrint(
          'Video duration received: ${duration.inSeconds}s (${duration.inMilliseconds}ms)',
        );

        if (duration.inMilliseconds > 0) {
          setState(() {
            _videoDuration = duration;
          });
          debugPrint(
            '✅ Video duration loaded successfully: ${duration.inSeconds}s',
          );
          _startProgressTimer();
        } else {
          debugPrint('⚠️ Video duration is 0 - video may not be ready yet');

          if (defaultTargetPlatform == TargetPlatform.android) {
            debugPrint('🤖 Android: Retrying duration load after 2 seconds...');
            Future.delayed(const Duration(seconds: 2), () {
              if (_videoDuration.inMilliseconds == 0) {
                _loadVideoDuration();
              }
            });
          }
        }
      } catch (e) {
        debugPrint('❌ Error loading video duration: $e');

        if (defaultTargetPlatform == TargetPlatform.android) {
          Future.delayed(const Duration(seconds: 2), () {
            _loadVideoDuration();
          });
        }
      }
    }
  }

  void _startProgressTimer() {
    _stopProgressTimer();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateProgress();
    });
    debugPrint('🎬 Progress timer started');
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
    debugPrint('🎬 Progress timer stopped');
  }

  void _updateProgress() async {
    if (_platformViewId != null) {
      try {
        final position = await getCurrentPosition();
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      } catch (e) {
        debugPrint('Error updating Brightcove progress: $e');
      }
    }
  }

  // Getters for progress tracking
  Duration get videoDuration => _videoDuration;
  Duration get currentPosition => _currentPosition;
  bool get isVideoReadyState => _isVideoReady;
}
