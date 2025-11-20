import Flutter
import UIKit
import BrightcovePlayerSDK

class BrightcovePlayerView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var _playerView: BCOVPUIPlayerView?
    private var _playbackController: BCOVPlaybackController?
    private var _methodChannel: FlutterMethodChannel?
    private var _viewId: Int64

    // Store current session for duration/position access
    private var currentSession: BCOVPlaybackSession?

    // Brightcove credentials (same as Android implementation)


    // Playback service
    private lazy var playbackService: BCOVPlaybackService = {
        let factory = BCOVPlaybackServiceRequestFactory(withAccountId: kAccountId, policyKey: kPolicyKey)
        return BCOVPlaybackService(withRequestFactory: factory)
    }()

    init(
        frame: CGRect,
        viewIdentifier: Int64,
        arguments: Any?,
        binaryMessenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        _viewId = viewIdentifier
        super.init()

        // Setup method channel for communication with Flutter
        _methodChannel = FlutterMethodChannel(
            name: "com.example.addToApp",
            binaryMessenger: binaryMessenger
        )
        _methodChannel?.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call, result: result)
        }

        // Store this instance in the manager
        BrightcovePlayerViewManager.shared.storeInstance(self, forId: Int(viewIdentifier))

        setupBrightcovePlayer()
    }

    func view() -> UIView {
        return _view
    }

    private func setupBrightcovePlayer() {
        print("🎬 Setting up iOS Brightcove player for viewId: \(_viewId)")

        // Create playback controller (using correct Brightcove SDK method)
        let sharedSDKManager = BCOVPlayerSDKManager.sharedManager()
        let playbackController = sharedSDKManager.createPlaybackController()
        _playbackController = playbackController

        // Configure playback controller
        playbackController.delegate = self
        playbackController.isAutoAdvance = true
        playbackController.isAutoPlay = true

        // Create player view
        guard let playerView = BCOVPUIPlayerView(playbackController: playbackController, options: nil, controlsView: BCOVPUIBasicControlView.withVODLayout()) else {
            print("❌ Failed to create iOS Brightcove player view")
            return
        }

        _playerView = playerView

        // Add to main view
        _view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: _view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: _view.bottomAnchor)
        ])

        // Hide default controls
        hidePlayerControls()

        // Load video
        loadVideo()
    }

    private func hidePlayerControls() {
        _playerView?.controlsView?.isHidden = true
        _playerView?.isUserInteractionEnabled = false
    }

    private func loadVideo() {
        print("🎬 Loading iOS Brightcove video with ID: \(kVideoId)")

        let configuration = [BCOVPlaybackService.ConfigurationKeyAssetID: kVideoId]
        playbackService.findVideo(withConfiguration: configuration, queryParameters: nil) { [weak self] (video: BCOVVideo?, jsonResponse: Any?, error: Error?) in
            guard let self = self,
                  let video = video else {
                if let error = error {
                    print("❌ Error loading iOS Brightcove video: \(error.localizedDescription)")
                }
                return
            }

            DispatchQueue.main.async {
                print("✅ iOS Brightcove video loaded successfully")
                self._playbackController?.setVideos([video])
                // Start playing automatically (matching Android behavior)
                self._playbackController?.play()
            }
        }
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("📞 iOS Brightcove method call: \(call.method)")

        switch call.method {
        case "playVideo":
            if let args = call.arguments as? [String: Any],
               let viewId = args["viewId"] as? Int {
                print("🎬 iOS playVideo called for viewId: \(viewId)")
                _playbackController?.play()
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId is required", details: nil))
            }

        case "pauseVideo":
            if let args = call.arguments as? [String: Any],
               let viewId = args["viewId"] as? Int {
                print("🎬 iOS pauseVideo called for viewId: \(viewId)")
                _playbackController?.pause()
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId is required", details: nil))
            }

        case "stop":
            _playbackController?.pause()
            result(nil)

        case "isPlaying":
            // Check if video is currently playing by checking the session state
            if let session = currentSession {
                let isPlaying = session.player?.rate ?? 0 > 0
                result(isPlaying)
            } else {
                result(false)
            }

        case "seekTo":
            if let args = call.arguments as? [String: Any],
               let position = args["position"] as? Int {
                let time = CMTime(seconds: Double(position) / 1000.0, preferredTimescale: 600)
                _playbackController?.seek(to: time, completionHandler: { _ in
                    result(nil)
                })
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid position", details: nil))
            }

        case "getVideoDuration":
            if let args = call.arguments as? [String: Any],
               let viewId = args["viewId"] as? Int {
                print("🎬 iOS getVideoDuration called for viewId: \(viewId)")
                let duration = getVideoDuration()
                result(duration)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId is required", details: nil))
            }

        case "getCurrentPosition":
            if let args = call.arguments as? [String: Any],
               let viewId = args["viewId"] as? Int {
                print("🎬 iOS getCurrentPosition called for viewId: \(viewId)")
                let position = getCurrentPosition()
                result(position)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId is required", details: nil))
            }

        case "checkVideoReady":
            if let args = call.arguments as? [String: Any],
               let viewId = args["viewId"] as? Int {
                print("🎬 iOS checkVideoReady called for viewId: \(viewId)")
                let isReady = isVideoReady()
                result(isReady)
            } else {
                result(false)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Video Control Methods (matching Android implementation)
    func playVideo() {
        print("🎬 iOS Brightcove: playVideo called")
        _playbackController?.play()
    }

    func pauseVideo() {
        print("🎬 iOS Brightcove: pauseVideo called")
        _playbackController?.pause()
    }

    func getVideoDuration() -> Int {
        print("🎬 iOS Brightcove: getVideoDuration called")

        // Method 1: Try to get duration from player's current item (MOST RELIABLE)
        if let session = currentSession,
           let playerItem = session.player?.currentItem {
            let duration = playerItem.duration
            let durationSeconds = CMTimeGetSeconds(duration)
            if durationSeconds > 0 {
                print("🎬 ✅ iOS video duration from player item: \(durationSeconds) seconds")
                return Int(durationSeconds * 1000)
            }
        }

        // Method 2: Try to get duration from video properties (FALLBACK)
        if let session = currentSession,
           let video = session.video,
           let duration = video.properties["duration"] as? NSNumber {
            let durationSeconds = duration.doubleValue
            print("🎬 ⚠️ iOS video duration from properties: \(durationSeconds) seconds (may be incorrect)")
            // Only use this if it's a reasonable value (less than 1 hour)
            if durationSeconds > 0 && durationSeconds < 3600 {
                return Int(durationSeconds * 1000)
            }
        }

        print("🎬 iOS: Could not get video duration - video may not be loaded yet")
        return 0
    }

    func getCurrentPosition() -> Int {
        print("🎬 iOS Brightcove: getCurrentPosition called")
        if let session = currentSession,
           let player = session.player {
            // Get current time from the player's current time
            let currentTime = player.currentTime()
            let positionSeconds = CMTimeGetSeconds(currentTime)
            print("🎬 iOS current position: \(positionSeconds) seconds")
            return Int(positionSeconds * 1000) // Return in milliseconds
        }
        print("🎬 iOS: Could not get current position")
        return 0
    }

    func isVideoReady() -> Bool {
        print("🎬 iOS Brightcove: isVideoReady called")
        if let session = currentSession,
           let video = session.video,
           let duration = video.properties["duration"] as? NSNumber {
            let durationSeconds = duration.doubleValue
            return durationSeconds > 0
        }
        return false
    }

    deinit {
        print("🎬 iOS Brightcove player view deallocated for viewId: \(_viewId)")
        BrightcovePlayerViewManager.shared.removeInstance(forId: Int(_viewId))
    }
}

// MARK: - BCOVPlaybackControllerDelegate
extension BrightcovePlayerView: BCOVPlaybackControllerDelegate {
    func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        print("🎬 iOS Brightcove: Video advanced to new session")
        // Store the current session for duration/position access
        currentSession = session

        // Send video start event to Flutter
        _methodChannel?.invokeMethod("onVideoStart", arguments: nil)
    }

    func playbackController(_ controller: BCOVPlaybackController!, playbackSession session: BCOVPlaybackSession!, didReceive lifecycleEvent: BCOVPlaybackSessionLifecycleEvent!) {
        print("🎬 iOS Brightcove: Playback lifecycle event: \(lifecycleEvent.eventType)")

        // Store the current session when it becomes available
        if lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventReady {
            currentSession = session
            print("🎬 iOS: Video session is READY!")
        }

        switch lifecycleEvent.eventType {
        case kBCOVPlaybackSessionLifecycleEventPlay:
            _methodChannel?.invokeMethod("onVideoPlay", arguments: nil)

        case kBCOVPlaybackSessionLifecycleEventPause:
            _methodChannel?.invokeMethod("onVideoPause", arguments: nil)

        case kBCOVPlaybackSessionLifecycleEventEnd:
            _methodChannel?.invokeMethod("onVideoEnd", arguments: nil)

        default:
            break
        }
    }
}

// MARK: - FlutterPlatformViewFactory
class BrightcovePlayerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var _messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        _messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return BrightcovePlayerView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: _messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - Player View Instances Storage
class BrightcovePlayerViewManager {
    static let shared = BrightcovePlayerViewManager()
    private var viewInstances = [Int: BrightcovePlayerView]()

    func storeInstance(_ view: BrightcovePlayerView, forId viewId: Int) {
        viewInstances[viewId] = view
        print("🎬 iOS: Stored Brightcove player instance for viewId: \(viewId)")
    }

    func getInstance(forId viewId: Int) -> BrightcovePlayerView? {
        return viewInstances[viewId]
    }

    func removeInstance(forId viewId: Int) {
        viewInstances.removeValue(forKey: viewId)
        print("🎬 iOS: Removed Brightcove player instance for viewId: \(viewId)")
    }

    // MARK: - Video Control Methods (matching Android implementation)
    func playVideo(viewId: Int) {
        if let view = getInstance(forId: viewId) {
            view.playVideo()
        }
    }

    func pauseVideo(viewId: Int) {
        if let view = getInstance(forId: viewId) {
            view.pauseVideo()
        }
    }

    func getVideoDuration(viewId: Int) -> Int {
        if let view = getInstance(forId: viewId) {
            return view.getVideoDuration()
        }
        return 0
    }

    func getCurrentPosition(viewId: Int) -> Int {
        if let view = getInstance(forId: viewId) {
            return view.getCurrentPosition()
        }
        return 0
    }

    func isVideoReady(viewId: Int) -> Bool {
        if let view = getInstance(forId: viewId) {
            return view.isVideoReady()
        }
        return false
    }
}
