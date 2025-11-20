# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-20

### Added
- Initial release of `brightcove_player_flutter`
- Support for Android and iOS platforms
- `BrightcovePlayerWidget` widget for easy integration
- Video playback controls (play, pause, seek)
- Progress tracking with duration and current position
- Event callbacks for video state changes:
  - `onVideoStart` - Triggered when video starts
  - `onVideoPlay` - Triggered when video plays
  - `onVideoPause` - Triggered when video pauses
  - `onVideoEnd` - Triggered when video ends
- Audio focus management for Android
- Support for custom account ID, policy key, and video ID
- Platform-specific implementations:
  - Android: Brightcove ExoPlayer integration
  - iOS: Brightcove Player SDK integration
- Method channel communication between Flutter and native platforms
- Video duration and position tracking
- Seek functionality with position updates
- Video ready state checking

### Features
- **Cross-platform support**: Works on both Android and iOS
- **Native performance**: Uses native Brightcove SDKs for optimal playback
- **Easy integration**: Simple widget-based API
- **Event-driven**: Comprehensive callback system for video events
- **Progress tracking**: Real-time video progress updates
- **Audio management**: Proper audio focus handling on Android

### Technical Details
- Android: Uses Brightcove ExoPlayer SDK with audio focus management
- iOS: Uses Brightcove Player SDK with BCOVPlaybackController
- Flutter: Platform views for native UI integration
- Method channels for bidirectional communication

## [Unreleased]

### Planned


