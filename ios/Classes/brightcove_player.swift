// import Flutter
// import UIKit
//
// public class ReelsPlugin: NSObject, FlutterPlugin {
//   public static func register(with registrar: FlutterPluginRegistrar) {
//     let channel = FlutterMethodChannel(name: "com.example.addToApp", binaryMessenger: registrar.messenger())
//     let instance = ReelsPlugin()
//     registrar.addMethodCallDelegate(instance, channel: channel)
//
//     // Register the Brightcove platform view factory
//     let factory = BrightcovePlayerViewFactory(messenger: registrar.messenger())
//     registrar.register(factory, withId: "brightcove_player")
//
//     print("✅ iOS ReelsPlugin: Brightcove platform view factory registered")
//   }
//
//   public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//     print("📞 iOS ReelsPlugin method call: \(call.method)")
//
//     switch call.method {
//     case "getPlatformVersion":
//       result("iOS " + UIDevice.current.systemVersion)
//
//     case "playVideo":
//       if let args = call.arguments as? [String: Any],
//          let viewId = args["viewId"] as? Int {
//         print("🎬 iOS ReelsPlugin: playVideo called for viewId: \(viewId)")
//         BrightcovePlayerViewManager.shared.playVideo(viewId: viewId)
//         result(true)
//       } else {
//         result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId is required", details: nil))
//       }
//
//     case "pauseVideo":
//       if let args = call.arguments as? [String: Any],
//          let viewId = args["viewId"] as? Int {
//         print("🎬 iOS ReelsPlugin: pauseVideo called for viewId: \(viewId)")
//         BrightcovePlayerViewManager.shared.pauseVideo(viewId: viewId)
//         result(true)
//       } else {
//         result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId is required", details: nil))
//       }
//
//     case "getVideoDuration":
//       if let args = call.arguments as? [String: Any],
//          let viewId = args["viewId"] as? Int {
//         print("🎬 iOS ReelsPlugin: getVideoDuration called for viewId: \(viewId)")
//         let duration = BrightcovePlayerViewManager.shared.getVideoDuration(viewId: viewId)
//         result(duration)
//       } else {
//         result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId is required", details: nil))
//       }
//
//     case "getCurrentPosition":
//       if let args = call.arguments as? [String: Any],
//          let viewId = args["viewId"] as? Int {
//         print("🎬 iOS ReelsPlugin: getCurrentPosition called for viewId: \(viewId)")
//         let position = BrightcovePlayerViewManager.shared.getCurrentPosition(viewId: viewId)
//         result(position)
//       } else {
//         result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId is required", details: nil))
//       }
//
//     case "checkVideoReady":
//       if let args = call.arguments as? [String: Any],
//          let viewId = args["viewId"] as? Int {
//         print("🎬 iOS ReelsPlugin: checkVideoReady called for viewId: \(viewId)")
//         let isReady = BrightcovePlayerViewManager.shared.isVideoReady(viewId: viewId)
//         result(isReady)
//       } else {
//         result(false)
//       }
//
//     default:
//       result(FlutterMethodNotImplemented)
//     }
//   }
// }
