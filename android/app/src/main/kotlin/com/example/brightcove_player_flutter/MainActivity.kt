package com.example.brightcove_player_flutter


import android.content.Context
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewFactory

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Register MethodChannel correctly
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.addToApp"
        )
        channel.setMethodCallHandler(this)
        
        // Set the MethodChannel in BrightcoveLayoutView so it can send events back
        BrightcoveLayoutView.setMethodChannel(channel)

        // 2. Register platform view
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "brightcove-player",
                BrightcoveLayoutViewFactory()
            )
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {

            "getPlatformVersion" -> {
                result.success("Android ${Build.VERSION.RELEASE}")
            }

            "playVideo" -> {
                val viewId = call.argument<Int>("viewId")
                if (viewId != null) {
                    BrightcoveLayoutView.playVideo(viewId)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId required", null)
                }
            }

            "pauseVideo" -> {
                val viewId = call.argument<Int>("viewId")
                if (viewId != null) {
                    BrightcoveLayoutView.pauseVideo(viewId)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId required", null)
                }
            }

            "getVideoDuration" -> {
                val viewId = call.argument<Int>("viewId")
                result.success(
                    viewId?.let { BrightcoveLayoutView.getVideoDuration(it) } ?: 0
                )
            }

            "getCurrentPosition" -> {
                val viewId = call.argument<Int>("viewId")
                result.success(
                    viewId?.let { BrightcoveLayoutView.getCurrentPosition(it) } ?: 0
                )
            }

            "seekToPosition" -> {
                val viewId = call.argument<Int>("viewId")
                val positionMs = call.argument<Int>("positionMs")
                if (viewId != null && positionMs != null) {
                    BrightcoveLayoutView.seekToPosition(viewId, positionMs.toLong())
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId & positionMs required", null)
                }
            }

            else -> result.notImplemented()
        }
    }
}
