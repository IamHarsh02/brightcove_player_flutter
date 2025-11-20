/// Example Usage Guide for Brightcove Player Flutter Plugin
///
/// This file contains code examples and comments demonstrating how to use
/// the BrightcovePlayerWidget in your Flutter application.
///
/// IMPORTANT: This is a documentation file, not a runnable app.
/// Copy and adapt these examples into your own Flutter project.

// ============================================================================
// STEP 1: Import the package
// ============================================================================
// Add this import to your Dart file:
// import 'package:brightcove_player_flutter/brightcove_player_flutter.dart';
// Or import directly:
// import 'package:brightcove_player_flutter/brightcove_player_widget.dart';

// ============================================================================
// STEP 2: Basic Usage - Simple Video Player
// ============================================================================
/*
To use the Brightcove player in your Flutter app, simply add the widget:

BrightcovePlayerWidget(
  width: double.infinity,
  height: 250,
  accountId: 'YOUR_ACCOUNT_ID',
  policyKey: 'YOUR_POLICY_KEY',
  videoId: 'YOUR_VIDEO_ID',
)
*/

// ============================================================================
// STEP 3: Basic Example with Event Callbacks
// ============================================================================
/*
Here's a complete example showing how to use the player with event callbacks:

class MyVideoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Player')),
      body: BrightcovePlayerWidget(
        width: double.infinity,
        height: 250,
        accountId: 'YOUR_ACCOUNT_ID',
        policyKey: 'YOUR_POLICY_KEY',
        videoId: 'YOUR_VIDEO_ID',
        onVideoStart: () {
          print('Video started');
        },
        onVideoPlay: () {
          print('Video playing');
        },
        onVideoPause: () {
          print('Video paused');
        },
        onVideoEnd: () {
          print('Video ended');
        },
      ),
    );
  }
}
*/

// ============================================================================
// STEP 4: Advanced Usage with Controls
// ============================================================================
/*
To control the player programmatically, use a GlobalKey:

class AdvancedVideoPlayer extends StatefulWidget {
  @override
  _AdvancedVideoPlayerState createState() => _AdvancedVideoPlayerState();
}

class _AdvancedVideoPlayerState extends State<AdvancedVideoPlayer> {
  // Create a GlobalKey to access player methods
  final GlobalKey<BrightcovePlayerWidgetState> _playerKey = GlobalKey();
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Player')),
      body: Column(
        children: [
          // Video Player
          Container(
            height: 250,
            color: Colors.black,
            child: BrightcovePlayerWidget(
              key: _playerKey,  // Assign the key
              width: double.infinity,
              height: 250,
              accountId: 'YOUR_ACCOUNT_ID',
              policyKey: 'YOUR_POLICY_KEY',
              videoId: 'YOUR_VIDEO_ID',
              onVideoPlay: () {
                setState(() => _isPlaying = true);
              },
              onVideoPause: () {
                setState(() => _isPlaying = false);
              },
            ),
          ),
          
          // Custom Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play/Pause Button
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (_isPlaying) {
                    _playerKey.currentState?.pause();
                  } else {
                    _playerKey.currentState?.play();
                  }
                },
              ),
              
              // Seek Backward 10 seconds
              IconButton(
                icon: Icon(Icons.replay_10),
                onPressed: () async {
                  final currentPos = _playerKey.currentState?.currentPosition ?? Duration.zero;
                  await _playerKey.currentState?.seekTo(
                    Duration(milliseconds: currentPos.inMilliseconds - 10000),
                  );
                },
              ),
              
              // Seek Forward 10 seconds
              IconButton(
                icon: Icon(Icons.forward_10),
                onPressed: () async {
                  final currentPos = _playerKey.currentState?.currentPosition ?? Duration.zero;
                  await _playerKey.currentState?.seekTo(
                    Duration(milliseconds: currentPos.inMilliseconds + 10000),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/

// ============================================================================
// STEP 5: Progress Tracking
// ============================================================================
/*
To track video progress, access the player's duration and position:

class ProgressTracker extends StatefulWidget {
  final GlobalKey<BrightcovePlayerWidgetState> playerKey;
  
  const ProgressTracker({required this.playerKey});
  
  @override
  _ProgressTrackerState createState() => _ProgressTrackerState();
}

class _ProgressTrackerState extends State<ProgressTracker> {
  @override
  Widget build(BuildContext context) {
    // Get current position and duration
    final position = widget.playerKey.currentState?.currentPosition ?? Duration.zero;
    final duration = widget.playerKey.currentState?.videoDuration ?? Duration.zero;
    
    // Calculate progress (0.0 to 1.0)
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;
    
    return Slider(
      value: progress,
      onChanged: (value) async {
        // Seek to new position when slider is moved
        final seekPos = Duration(
          milliseconds: (value * duration.inMilliseconds).toInt(),
        );
        await widget.playerKey.currentState?.seekTo(seekPos);
      },
    );
  }
}
*/

// ============================================================================
// STEP 6: Available Methods
// ============================================================================
/*
The BrightcovePlayerWidgetState provides these methods:

// Play the video
playerKey.currentState?.play();

// Pause the video
playerKey.currentState?.pause();

// Seek to a specific position
await playerKey.currentState?.seekTo(Duration(seconds: 30));

// Get video duration (async)
final duration = await playerKey.currentState?.getVideoDuration();

// Get current position (async)
final position = await playerKey.currentState?.getCurrentPosition();

// Check if video is ready (async)
final isReady = await playerKey.currentState?.isVideoReady();
*/

// ============================================================================
// STEP 7: Available Getters
// ============================================================================
/*
Access these properties directly (no async needed):

// Get current video duration
final duration = playerKey.currentState?.videoDuration;

// Get current playback position
final position = playerKey.currentState?.currentPosition;

// Check if video is ready
final isReady = playerKey.currentState?.isVideoReadyState;
*/

// ============================================================================
// STEP 8: Event Callbacks
// ============================================================================
/*
The widget supports these event callbacks:

BrightcovePlayerWidget(
  // Called when video starts loading/playing
  onVideoStart: () {
    print('Video started');
  },
  
  // Called when playback begins
  onVideoPlay: () {
    print('Video playing');
  },
  
  // Called when playback is paused
  onVideoPause: () {
    print('Video paused');
  },
  
  // Called when playback completes
  onVideoEnd: () {
    print('Video ended');
  },
)
*/

// ============================================================================
// STEP 9: Complete Example with All Features
// ============================================================================
/*
Here's a complete example combining all features:

import 'package:flutter/material.dart';
import 'package:brightcove_player_flutter/brightcove_player_flutter.dart';
import 'dart:async';

class CompleteVideoPlayer extends StatefulWidget {
  @override
  _CompleteVideoPlayerState createState() => _CompleteVideoPlayerState();
}

class _CompleteVideoPlayerState extends State<CompleteVideoPlayer> {
  final GlobalKey<BrightcovePlayerWidgetState> _playerKey = GlobalKey();
  bool _isPlaying = false;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    // Update progress every 100ms
    _progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {}); // Rebuild to update progress
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final position = _playerKey.currentState?.currentPosition ?? Duration.zero;
    final duration = _playerKey.currentState?.videoDuration ?? Duration.zero;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: Text('Video Player')),
      body: Column(
        children: [
          // Video Player
          Container(
            height: 250,
            color: Colors.black,
            child: BrightcovePlayerWidget(
              key: _playerKey,
              width: double.infinity,
              height: 250,
              accountId: 'YOUR_ACCOUNT_ID',
              policyKey: 'YOUR_POLICY_KEY',
              videoId: 'YOUR_VIDEO_ID',
              onVideoStart: () => setState(() => _isPlaying = true),
              onVideoPlay: () => setState(() => _isPlaying = true),
              onVideoPause: () => setState(() => _isPlaying = false),
              onVideoEnd: () => setState(() => _isPlaying = false),
            ),
          ),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  _isPlaying
                      ? _playerKey.currentState?.pause()
                      : _playerKey.currentState?.play();
                },
              ),
              IconButton(
                icon: Icon(Icons.replay_10),
                onPressed: () async {
                  final newPos = Duration(
                    milliseconds: (position.inMilliseconds - 10000).clamp(0, double.infinity).toInt(),
                  );
                  await _playerKey.currentState?.seekTo(newPos);
                },
              ),
              IconButton(
                icon: Icon(Icons.forward_10),
                onPressed: () async {
                  final newPos = Duration(
                    milliseconds: (position.inMilliseconds + 10000)
                        .clamp(0, duration.inMilliseconds)
                        .toInt(),
                  );
                  await _playerKey.currentState?.seekTo(newPos);
                },
              ),
            ],
          ),
          
          // Progress Bar
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Slider(
                  value: progress,
                  onChanged: (value) async {
                    final seekPos = Duration(
                      milliseconds: (value * duration.inMilliseconds).toInt(),
                    );
                    await _playerKey.currentState?.seekTo(seekPos);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position)),
                    Text(_formatDuration(duration)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

// ============================================================================
// NOTES
// ============================================================================
/*
IMPORTANT SETUP REQUIREMENTS:

1. Android Setup:
   - Add Brightcove repository to android/build.gradle.kts
   - Add Brightcove dependencies to android/app/build.gradle.kts
   - Minimum SDK version: 21

2. iOS Setup:
   - Add Brightcove pods to ios/Podfile
   - Run: cd ios && pod install
   - Minimum iOS version: 13.0

3. Replace Credentials:
   - Replace 'YOUR_ACCOUNT_ID' with your Brightcove account ID
   - Replace 'YOUR_POLICY_KEY' with your Brightcove policy key
   - Replace 'YOUR_VIDEO_ID' with your video ID

For detailed setup instructions, see the README.md file.
*/
