# Brightcove Player Flutter - Detailed Implementation Guide

This guide provides step-by-step instructions for integrating the Brightcove video player into your Flutter project.

---

## Table of Contents

1. [Add Package from pub.dev](#1-add-package-from-pubdev)
2. [Android Implementation](#android-implementation)
   - [Step 2: Add Build Gradle Dependencies](#step-2-add-build-gradle-dependencies)
   - [Step 3: Create BrightCovePlayer.kt](#step-3-create-brightcoveplayerkt)
   - [Step 4: Update MainActivity.kt](#step-4-update-mainactivitykt)
   - [Step 5: Create Layout File and Add Imports](#step-5-create-layout-file-and-add-imports)
   - [Step 6: Add Your Credentials](#step-6-add-your-credentials)
3. [iOS Implementation](#ios-implementation)
   - [Step 7: Update AppDelegate.swift](#step-7-update-appdelegateswift)
   - [Step 8: Add BrightCovePlayerView.swift](#step-8-add-brightcoveplayerviewswift)
   - [Step 9: Update Podfile](#step-9-update-podfile)
   - [Step 10: Run Pod Install](#step-10-run-pod-install)
   - [Step 11: Info.plist Configuration](#step-11-infoplist-configuration)

---

## 1. Add Package from pub.dev

### Step 1.1: Add to pubspec.yaml

Open your `pubspec.yaml` file and add the package:

```yaml
dependencies:
  flutter:
    sdk: flutter
  brightcove_player_flutter: ^1.0.0
```

### Step 1.2: Install the Package

Run the following command in your terminal:

```bash
flutter pub get
```

---

## Android Implementation

## Step 2: Add Build Gradle Dependencies

### Step 2.1: Update `android/build.gradle.kts`

Open `android/build.gradle.kts` and add the Brightcove repository to the `allprojects` block:

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

### Step 2.2: Update `android/app/build.gradle.kts`

Open `android/app/build.gradle.kts` and:

1. **Add the Brightcove repository** in the `repositories` block:

```kotlin
repositories {
    maven {
        url = uri("https://repo.brightcove.com/releases")
    }
    google()
    mavenCentral()
}
```

2. **Add Brightcove dependencies** in the `dependencies` block:

```kotlin
dependencies {
    implementation("com.brightcove.player:exoplayer2:6.19.1")
    implementation("com.brightcove.player:android-sdk:6.19.1")
}
```

3. **Set minimum SDK version** (if not already set):

```kotlin
android {
    defaultConfig {
        minSdk = 21  // Minimum required for Brightcove
    }
}
```

### Step 2.3: Sync Gradle

After making these changes, sync your Gradle files in Android Studio or run:

```bash
cd android
./gradlew build
```

---

## Step 3: Create BrightCovePlayer.kt

### Step 3.1: Create the File

Create a new file at:
```
android/app/src/main/kotlin/com/example/brightcove_player_flutter/BrightCovePlayer.kt
```

**Note:** Replace `com.example.brightcove_player_flutter` with your actual package name.

### Step 3.2: Copy the Complete Code

Copy the entire content from the provided `BrightCovePlayer.kt` file. The file should include:

- `BrightcoveLayoutViewFactory` class
- `BrightcoveLayoutView` class with:
  - Companion object for static methods
  - Audio focus management
  - Video initialization
  - Event listeners
  - Playback control methods

**Important:** Make sure the package name at the top matches your project's package name:

```kotlin
package com.example.brightcove_player_flutter  // Change this to your package name
```

---

## Step 4: Update MainActivity.kt

### Step 4.1: Open MainActivity.kt

Open `android/app/src/main/kotlin/com/example/brightcove_player_flutter/MainActivity.kt`

### Step 4.2: Replace the Content

Replace the entire content with the provided `MainActivity.kt` code. The key parts are:

1. **Implement MethodChannel.MethodCallHandler**:

```kotlin
class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    // ...
}
```

2. **Register MethodChannel and Platform View** in `configureFlutterEngine`:

```kotlin
override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    // Register MethodChannel
    channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "com.example.addToApp"
    )
    channel.setMethodCallHandler(this)
    
    // Set MethodChannel for BrightcoveLayoutView
    BrightcoveLayoutView.setMethodChannel(channel)
    
    // Register platform view factory
    flutterEngine.platformViewsController.registry.registerViewFactory(
        "brightcove-player",
        BrightcoveLayoutViewFactory()
    )
}
```

3. **Handle Method Calls** in `onMethodCall`:

```kotlin
override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
        "playVideo" -> { /* ... */ }
        "pauseVideo" -> { /* ... */ }
        "getVideoDuration" -> { /* ... */ }
        "getCurrentPosition" -> { /* ... */ }
        "seekToPosition" -> { /* ... */ }
        else -> result.notImplemented()
    }
}
```

**Important:** Make sure the package name matches your project.

---

## Step 5: Create Layout File and Add Imports

### Step 5.1: Create Layout Directory (if it doesn't exist)

Create the directory structure:
```
android/app/src/main/res/layout/
```

### Step 5.2: Create brightcove_platform_view.xml

Create a new file: `android/app/src/main/res/layout/brightcove_platform_view.xml`

Add the following content:

```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <com.brightcove.player.view.BrightcoveExoPlayerVideoView
        android:id="@+id/brightcove_video_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />

</FrameLayout>
```

### Step 5.3: Verify Imports in BrightCovePlayer.kt

Make sure `BrightCovePlayer.kt` has all necessary imports. The file should include:

```kotlin
package com.example.brightcove_player_flutter
import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.media.AudioManager
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import com.brightcove.player.edge.Catalog
import com.brightcove.player.edge.VideoListener
import com.brightcove.player.model.Video
import com.brightcove.player.view.BrightcoveExoPlayerVideoView
import com.brightcove.player.event.EventType
import com.brightcove.player.mediacontroller.ShowHideController.HIDE_MEDIA_CONTROLS
import com.brightcove.player.event.Event
import com.brightcove.player.event.EventListener
import io.flutter.plugin.common.MethodChannel
```

**Note:** The layout file is referenced in `BrightCovePlayer.kt` at line 109:
```kotlin
rootView = inflater.inflate(R.layout.brightcove_platform_view, null)
```

---

## Step 6: Add Your Credentials

### Step 6.1: Update BrightCovePlayer.kt

In `BrightCovePlayer.kt`, find the `initializeVideo()` method (around line 139) and update the default values:

```kotlin
private fun initializeVideo() {
    // Extract parameters from creationParams
    val account = (creationParams?.get("accountId") as? String) 
        ?: (creationParams?.get("account") as? String) 
        ?: "YOUR_ACCOUNT_ID"  // Replace with your Brightcove Account ID
    
    val policy = (creationParams?.get("policyKey") as? String)
        ?: (creationParams?.get("policy") as? String)
        ?: "YOUR_POLICY_KEY"  // Replace with your Brightcove Policy Key
    
    val videoId = creationParams?.get("videoId") as? String
        ?: "YOUR_VIDEO_ID"  // Replace with your Video ID
    // ...
}
```

**Alternatively**, you can pass these values from Flutter when creating the widget (recommended):

```dart
BrightcovePlayerWidget(
  accountId: 'YOUR_ACCOUNT_ID',
  policyKey: 'YOUR_POLICY_KEY',
  videoId: 'YOUR_VIDEO_ID',
  // ...
)
```

### Step 6.2: Get Your Brightcove Credentials

1. **Account ID**: Found in your Brightcove Studio account settings
2. **Policy Key**: Created in Brightcove Studio under API Authentication
3. **Video ID**: The ID of the video you want to play (found in Video Cloud)

---

## Android Implementation Complete! ✅

At this point, your Android implementation should be complete. Test it by running:

```bash
flutter run
```

---

## iOS Implementation

## Step 7: Update AppDelegate.swift

### Step 7.1: Open AppDelegate.swift

Open `ios/Runner/AppDelegate.swift`

### Step 7.2: Replace the Content

Replace the entire content with the provided `AppDelegate.swift` code:

```swift
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
```

---

## Step 8: Add BrightCovePlayerView.swift

### Step 8.1: Create the File in Code

Create a new file at:
```
ios/Runner/BrightCovePlayerView.swift
```

### Step 8.2: Copy the Complete Code

Copy the entire content from the provided `BrightCovePlayerView.swift` file. This file includes:

- `BrightcovePlayerView` class implementing `FlutterPlatformView`
- `BCOVPlaybackControllerDelegate` extension
- `BrightcovePlayerViewFactory` class
- `BrightcovePlayerViewManager` class

**Important:** Make sure to update the credentials in the file. Look for constants like `kAccountId`, `kPolicyKey`, and `kVideoId` and replace them, OR modify the `init` method to read from `arguments` (as shown in the provided code).

### Step 8.3: Add File to Xcode Project

**This is a critical step!** The file must be added to the Xcode project target:

1. **Open Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```
   ⚠️ **Important:** Open `.xcworkspace`, NOT `.xcodeproj`

2. **In Xcode**:
   - Navigate to: `Runner.xcodeproj` → `Runner` folder
   - Right-click on the `Runner` folder
   - Select: **"Add Files to Runner..."**
   - Navigate to and select: `ios/Runner/BrightCovePlayerView.swift`
   - **IMPORTANT:** Check the box **"Copy items if needed"** (if file is outside project)
   - **IMPORTANT:** Make sure **"Runner"** is selected in the **"Add to targets"** section
   - Click **"Add"**

3. **Verify Target Membership**:
   - Select `BrightCovePlayerView.swift` in the project navigator
   - Open the **File Inspector** (right panel, first icon)
   - Under **"Target Membership"**, ensure **"Runner"** is checked ✅

4. **Verify Build Settings**:
   - Select the **Runner** project in the navigator
   - Select the **Runner** target
   - Go to **Build Settings**
   - Search for **"Swift Language Version"**
   - Ensure it's set to **Swift 5** or later

### Step 8.4: Update Credentials in BrightCovePlayerView.swift

In `BrightCovePlayerView.swift`, the credentials should be read from `arguments` passed from Flutter. The `init` method should extract them:

```swift
init(
    frame: CGRect,
    viewIdentifier: Int64,
    arguments: Any?,
    binaryMessenger: FlutterBinaryMessenger
) {
    _view = UIView()
    _viewId = viewIdentifier
    
    // Extract credentials from arguments
    let params = arguments as? [String: Any]
    let accountId = (params?["accountId"] as? String) ?? "YOUR_ACCOUNT_ID"
    let policyKey = (params?["policyKey"] as? String) ?? "YOUR_POLICY_KEY"
    let videoId = (params?["videoId"] as? String) ?? "YOUR_VIDEO_ID"
    
    // Use these in your playbackService initialization
    // ...
}
```

---

## Step 9: Update Podfile

### Step 9.1: Open Podfile

Open `ios/Podfile`

### Step 9.2: Update the Content

Replace the `target 'Runner' do` block with:

```ruby
target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Brightcove Player SDK
  pod 'Brightcove-Player-Core'
  pod 'Brightcove-Player-IMA'
  pod 'GoogleAds-IMA-iOS-SDK'
end
```

### Step 9.3: Add Brightcove Spec Repo (if not present)

At the top of the Podfile, ensure you have:

```ruby
platform :ios, '13.0'

# Brightcove spec repo
source 'https://github.com/brightcove/BrightcoveSpecs.git'
source 'https://cdn.cocoapods.org/'
```

### Step 9.4: Ensure Minimum iOS Version

In the `post_install` block, ensure:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

---

## Step 10: Run Pod Install

### Step 10.1: Navigate to iOS Directory

```bash
cd ios
```

### Step 10.2: Install Pods

```bash
pod install
```

### Step 10.3: Return to Project Root

```bash
cd ..
```

### Step 10.4: Clean and Rebuild (Recommended)

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

**Expected Output:**
You should see the Brightcove pods being installed:
```
Installing Brightcove-Player-Core (x.x.x)
Installing Brightcove-Player-IMA (x.x.x)
Installing GoogleAds-IMA-iOS-SDK (x.x.x)
```

---

## Step 11: Info.plist Configuration

### Step 11.1: Open Info.plist

Open `ios/Runner/Info.plist`

### Step 11.2: Add Required Keys

For Brightcove video playback, you typically need:

1. **Network Permissions** (usually handled automatically by Flutter, but verify):

The following keys are typically **NOT required** for Brightcove as it uses HTTPS, but if you encounter network issues, you can add:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>brightcove.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

**Note:** This is usually **NOT needed** since Brightcove uses HTTPS.

2. **Background Modes** (if you want background playback):

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

3. **Required Device Capabilities** (usually already present):

```xml
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>armv7</string>
</array>
```

### Step 11.3: Verify Minimum iOS Version

Ensure your `Info.plist` doesn't override the minimum iOS version. The deployment target should be set in:
- `Podfile` (platform :ios, '13.0')
- Xcode project settings (iOS Deployment Target: 13.0)

### What We Actually Added/Modified in Info.plist

For a standard Brightcove implementation, **no changes to Info.plist are typically required**. The default Flutter `Info.plist` should work fine because:

1. ✅ **Network access** is enabled by default in Flutter apps
2. ✅ **HTTPS** is used by Brightcove (no special ATS exceptions needed)
3. ✅ **Video playback** doesn't require special permissions

**However**, if you need specific features, you might add:

- **Background audio playback** (if implementing background video):
  ```xml
  <key>UIBackgroundModes</key>
  <array>
      <string>audio</string>
  </array>
  ```

- **Camera/Microphone access** (only if your videos require it):
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>We need camera access for video recording</string>
  <key>NSMicrophoneUsageDescription</key>
  <string>We need microphone access for video recording</string>
  ```

**For standard video playback, no Info.plist changes are needed!** ✅

---

## iOS Implementation Complete! ✅

At this point, your iOS implementation should be complete. Test it by running:

```bash
flutter run
```

---

## Verification Checklist

### Android ✅
- [ ] Package added to `pubspec.yaml`
- [ ] Brightcove repository added to `build.gradle.kts`
- [ ] Brightcove dependencies added to `app/build.gradle.kts`
- [ ] `BrightCovePlayer.kt` created with correct package name
- [ ] `MainActivity.kt` updated with MethodChannel and platform view registration
- [ ] `brightcove_platform_view.xml` layout file created
- [ ] Credentials updated (or passed from Flutter)
- [ ] Gradle sync successful

### iOS ✅
- [ ] Package added to `pubspec.yaml`
- [ ] `AppDelegate.swift` updated
- [ ] `BrightCovePlayerView.swift` created
- [ ] `BrightCovePlayerView.swift` added to Xcode project target
- [ ] Target membership verified in Xcode
- [ ] Podfile updated with Brightcove pods
- [ ] `pod install` completed successfully
- [ ] Credentials updated in `BrightCovePlayerView.swift`
- [ ] Info.plist verified (no changes typically needed)

---

## Troubleshooting

### Android Issues

**Issue:** "Unresolved reference: BrightcoveExoPlayerVideoView"
- **Solution:** Ensure Brightcove dependencies are added and Gradle is synced

**Issue:** "Layout file not found"
- **Solution:** Verify `brightcove_platform_view.xml` exists in `res/layout/`

**Issue:** "MethodChannel not working"
- **Solution:** Verify MethodChannel name matches in both Kotlin and Dart code

### iOS Issues

**Issue:** "No such module 'BrightcovePlayerSDK'"
- **Solution:** Run `pod install` and ensure pods are installed

**Issue:** "Cannot find 'BrightcovePlayerViewFactory' in scope"
- **Solution:** Verify `BrightCovePlayerView.swift` is added to Xcode target

**Issue:** "PlatformException(unregistered_view_type)"
- **Solution:** Verify platform view factory is registered in `AppDelegate.swift`

**Issue:** Build errors after adding Swift file
- **Solution:** 
  1. Clean build folder in Xcode (Product → Clean Build Folder)
  2. Delete `ios/Pods` and `ios/Podfile.lock`
  3. Run `pod install` again
  4. Run `flutter clean` and `flutter pub get`

---

## Next Steps

1. **Test the Implementation**: Run `flutter run` on both Android and iOS
2. **Add Your Credentials**: Replace placeholder values with your actual Brightcove credentials
3. **Customize the Player**: Modify the widget properties and callbacks as needed
4. **Handle Errors**: Add error handling for network issues and invalid credentials

---

## Support

If you encounter issues:
1. Check the [README.md](README.md) for usage examples
2. Review the [example/example.dart](example/example.dart) for code samples
3. Open an issue on the GitHub repository

---

**Congratulations!** 🎉 Your Brightcove player integration is complete!

