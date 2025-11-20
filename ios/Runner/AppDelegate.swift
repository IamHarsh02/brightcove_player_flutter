import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Register Brightcove platform view factory
    // Note: This requires ReelsPlugin.swift and BrightcovePlayerViewFactory to be in Xcode target
    DispatchQueue.main.async {
      self.registerBrightcovePlatformView()
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func registerBrightcovePlatformView() {
    guard let controller = self.window?.rootViewController as? FlutterViewController else {
      print("❌ iOS: FlutterViewController not available")
      return
    }
    
    // Register Brightcove platform view factory directly
    // BrightCovePlayerView.swift is already in the Xcode project
    let factory = BrightcovePlayerViewFactory(messenger: controller.binaryMessenger)
    
    // Get registrar and register the factory
    if let registrar = self.registrar(forPlugin: "BrightcovePlayerPlugin") {
      registrar.register(factory, withId: "brightcove_player")
      print("✅ iOS: Brightcove platform view factory registered successfully")
    } else {
      // Alternative: get registrar from engine
      let engine = controller.engine
      let registrar = engine.registrar(forPlugin: "BrightcovePlayerPlugin")
      registrar?.register(factory, withId: "brightcove_player")
      print("✅ iOS: Brightcove platform view factory registered via engine")
    }
  }
}
