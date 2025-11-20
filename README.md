# brightcove_player_flutter

A Flutter plugin for integrating Brightcove video player into your Flutter applications. This plugin provides native Brightcove player support for both Android and iOS platforms.

## Features

- ✅ **Cross-platform support**: Android and iOS
- ✅ **Native performance**: Uses official Brightcove SDKs
- ✅ **Easy integration**: Simple widget-based API
- ✅ **Video controls**: Play, pause, seek functionality
- ✅ **Event callbacks**: Comprehensive video state callbacks
- ✅ **Progress tracking**: Real-time video progress updates
- ✅ **Audio management**: Proper audio focus handling
- ✅ **Customizable**: Support for custom account ID, policy key, and video ID

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  brightcove_player_flutter: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Platform Setup

> **⚠️ IMPORTANT SETUP REQUIREMENTS:**
> 
> Before using this plugin, you must complete the platform-specific setup:
> 
> 1. **Android Setup:**
>    - Add Brightcove repository to `android/build.gradle.kts`
>    - Add Brightcove dependencies to `android/app/build.gradle.kts`
>    - Minimum SDK version: 21
> 
> 2. **iOS Setup:**
>    - Add Brightcove pods to `ios/Podfile`
>    - Run: `cd ios && pod install`
>    - Minimum iOS version: 13.0
> 
> 3. **Replace Credentials:**
>    - Replace `'YOUR_ACCOUNT_ID'` with your Brightcove account ID
>    - Replace `'YOUR_POLICY_KEY'` with your Brightcove policy key
>    - Replace `'YOUR_VIDEO_ID'` with your video ID
> 
> See detailed instructions below.

### Android

#### 1. Update `android/app/build.gradle.kts`

Add the Brightcove repository and dependencies:

```kotlin
repositories {
    maven {
        url = uri("https://repo.brightcove.com/releases")
    }
    google()
    mavenCentral()
}

dependencies {
    implementation("com.brightcove.player:exoplayer2:6.19.1")
    implementation("com.brightcove.player:android-sdk:6.19.1")
}
```

#### 2. Update `android/build.gradle.kts`

Ensure you have the Brightcove repository:

```kotlin
allprojects {
    repositories {
        maven {
            url = uri("https://repo.brightcove.com/releases")
        }
        google()
        mavenCentral()
    }
}
```

#### 3. Minimum SDK Version

Ensure your `minSdkVersion` is at least 21 in `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        minSdk = 21
    }
}
```

### iOS

#### 1. Update `ios/Podfile`

Add Brightcove pods:

```ruby
platform :ios, '13.0'

source 'https://github.com/brightcove/BrightcoveSpecs.git'
source 'https://cdn.cocoapods.org/'

target 'Runner' do
  use_frameworks!

  pod 'Brightcove-Player-Core'
  pod 'Brightcove-Player-IMA'
  pod 'GoogleAds-IMA-iOS-SDK'
end
```

#### 2. Install Pods

```bash
cd ios
pod install
cd ..
```

#### 3. Minimum iOS Version

Ensure your iOS deployment target is at least 13.0.

## Usage

> **Note:** Make sure to replace `'YOUR_ACCOUNT_ID'`, `'YOUR_POLICY_KEY'`, and `'YOUR_VIDEO_ID'` with your actual Brightcove credentials in all examples below.

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:brightcove_player_flutter/brightcove_player_flutter.dart';
// Or import directly:
// import 'package:brightcove_player_flutter/brightcove_player_widget.dart';

class VideoPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Brightcove Player')),
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
```

### Advanced Example with Controls

```dart
import 'package:flutter/material.dart';
import 'package:brightcove_player_flutter/brightcove_player_flutter.dart';
// Or import directly:
// import 'package:brightcove_player_flutter/brightcove_player_widget.dart';

class AdvancedVideoPlayer extends StatefulWidget {
  @override
  _AdvancedVideoPlayerState createState() => _AdvancedVideoPlayerState();
}

class _AdvancedVideoPlayerState extends State<AdvancedVideoPlayer> {
  final GlobalKey<BrightcovePlayerWidgetState> _playerKey = GlobalKey();
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Brightcove Player')),
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
              onVideoStart: () {
                setState(() => _isPlaying = true);
              },
              onVideoPlay: () {
                setState(() => _isPlaying = true);
              },
              onVideoPause: () {
                setState(() => _isPlaying = false);
              },
              onVideoEnd: () {
                setState(() => _isPlaying = false);
              },
            ),
          ),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              IconButton(
                icon: Icon(Icons.replay_10),
                onPressed: () async {
                  final currentPos = _playerKey.currentState?.currentPosition ?? Duration.zero;
                  await _playerKey.currentState?.seekTo(
                    Duration(milliseconds: currentPos.inMilliseconds - 10000),
                  );
                },
              ),
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
          
          // Progress Bar
          StreamBuilder(
            stream: Stream.periodic(Duration(milliseconds: 100)),
            builder: (context, snapshot) {
              final duration = _playerKey.currentState?.videoDuration ?? Duration.zero;
              final position = _playerKey.currentState?.currentPosition ?? Duration.zero;
              final progress = duration.inMilliseconds > 0
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0;
              
              return Slider(
                value: progress,
                onChanged: (value) async {
                  final seekPos = Duration(
                    milliseconds: (value * duration.inMilliseconds).toInt(),
                  );
                  await _playerKey.currentState?.seekTo(seekPos);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## working example
https://github.com/user-attachments/assets/15fb2106-68c7-4c5d-b32b-168d05bed8fe

## API Reference

### BrightcovePlayerWidget

A widget that displays a Brightcove video player.

#### Properties

| Property | Type | Description | Required |
|----------|------|-------------|----------|
| `accountId` | `String?` | Your Brightcove account ID | No |
| `policyKey` | `String?` | Your Brightcove policy key | No |
| `videoId` | `String?` | The video ID to play | No |
| `width` | `double?` | Width of the player | No |
| `height` | `double?` | Height of the player | No |
| `onVideoStart` | `VoidCallback?` | Called when video starts | No |
| `onVideoPlay` | `VoidCallback?` | Called when video plays | No |
| `onVideoPause` | `VoidCallback?` | Called when video pauses | No |
| `onVideoEnd` | `VoidCallback?` | Called when video ends | No |

#### Methods (via GlobalKey)

Access methods through a `GlobalKey<BrightcovePlayerWidgetState>`:

```dart
final GlobalKey<BrightcovePlayerWidgetState> playerKey = GlobalKey();

// In your widget
BrightcovePlayerWidget(key: playerKey, ...)

// Later, control the player
playerKey.currentState?.play();
playerKey.currentState?.pause();
await playerKey.currentState?.seekTo(Duration(seconds: 30));
```

##### Available Methods

- `play()` - Start video playback
- `pause()` - Pause video playback
- `seekTo(Duration position)` - Seek to a specific position
- `getVideoDuration()` - Get video duration (async)
- `getCurrentPosition()` - Get current playback position (async)
- `isVideoReady()` - Check if video is ready (async)

##### Getters

- `videoDuration` - Current video duration
- `currentPosition` - Current playback position
- `isVideoReadyState` - Whether video is ready

## Event Callbacks

The widget provides several callbacks for video state changes:

- **onVideoStart**: Triggered when the video starts loading/playing
- **onVideoPlay**: Triggered when playback begins
- **onVideoPause**: Triggered when playback is paused
- **onVideoEnd**: Triggered when playback completes

## Platform-Specific Notes

### Android

- Requires minimum SDK version 21
- Audio focus is automatically managed
- Uses Brightcove ExoPlayer SDK

### iOS

- Requires minimum iOS version 13.0
- Uses Brightcove Player SDK
- Requires CocoaPods installation

## Troubleshooting

### Android: Audio not working

- Ensure audio focus is granted (handled automatically)
- Check device volume settings
- Verify audio permissions in AndroidManifest.xml

### iOS: Build errors

- Run `pod install` in the `ios` directory
- Ensure iOS deployment target is 13.0 or higher
- Clean build folder: `flutter clean`

### Video not loading

- Verify your account ID, policy key, and video ID are correct
- Check network connectivity
- Review native logs for error messages

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Brightcove](https://www.brightcove.com/) for providing the native SDKs
- Flutter team for the platform view support

## Support

For issues, feature requests, or questions, please open an issue on the [GitHub repository](https://github.com/yourusername/brightcove_player_flutter).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.
