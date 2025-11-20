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

class BrightcoveLayoutViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return BrightcoveLayoutView(context, viewId, creationParams)
    }
}

class BrightcoveLayoutView(
    private val context: Context,
    private val viewId: Int,
    private val creationParams: Map<String?, Any?>?
) : PlatformView {

    companion object {
        private val viewInstances = mutableMapOf<Int, BrightcoveLayoutView>()
        private var methodChannel: MethodChannel? = null

        fun setMethodChannel(channel: MethodChannel) {
            methodChannel = channel
        }

        fun getInstance(viewId: Int): BrightcoveLayoutView? {
            return viewInstances[viewId]
        }

        fun playVideo(viewId: Int) {
            getInstance(viewId)?.playVideo()
        }

        fun pauseVideo(viewId: Int) {
            getInstance(viewId)?.pauseVideo()
        }

        fun getVideoDuration(viewId: Int): Long {
            return getInstance(viewId)?.getVideoDuration() ?: 0L
        }

        fun getCurrentPosition(viewId: Int): Long {
            return getInstance(viewId)?.getCurrentPosition() ?: 0L
        }

        fun seekToPosition(viewId: Int, positionMs: Long) {
            getInstance(viewId)?.seekToPosition(positionMs)
        }

        private fun sendEventToFlutter(eventName: String, viewId: Int) {
            try {
                methodChannel?.invokeMethod(eventName, mapOf("viewId" to viewId))
                Log.d("BrightcoveLayoutView", "Sent event to Flutter: $eventName for viewId: $viewId")
            } catch (e: Exception) {
                Log.e("BrightcoveLayoutView", "Error sending event to Flutter: ${e.message}")
            }
        }

        fun sendVideoStartEvent(viewId: Int) {
            sendEventToFlutter("onVideoStart", viewId)
        }

        fun sendVideoPlayEvent(viewId: Int) {
            sendEventToFlutter("onVideoPlay", viewId)
        }

        fun sendVideoPauseEvent(viewId: Int) {
            sendEventToFlutter("onVideoPause", viewId)
        }

        fun sendVideoEndEvent(viewId: Int) {
            sendEventToFlutter("onVideoEnd", viewId)
        }
    }

    private val rootView: View
    private var brightcoveVideoView: BrightcoveExoPlayerVideoView? = null
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null

    init {
        Log.d("BrightcoveLayoutView", "Creating Brightcove platform view with ID: $viewId")

        // Register this instance
        viewInstances[viewId] = this

        // Inflate the layout file
        val inflater = LayoutInflater.from(context)
        rootView = inflater.inflate(R.layout.brightcove_platform_view, null)

        // Get the Brightcove video view from the layout
        brightcoveVideoView = rootView.findViewById(R.id.brightcove_video_view)

        // Get AudioManager for audio focus handling
        audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager

        // Configure audio attributes for proper audio playback
        brightcoveVideoView?.let { videoView ->
            try {
                videoView.setMediaController(null as android.widget.MediaController)
                Log.d("BrightcoveLayoutView", "MediaController set to null immediately")
                
                // Configure audio attributes for ExoPlayer
                configureAudioAttributes(videoView)
            } catch (e: Exception) {
                Log.d("BrightcoveLayoutView", "Immediate MediaController null setting failed: ${e.message}")
            }
        }

        // Initialize video after view is created
        rootView.post {
            initializeVideo()
//            hideBrightcoveControls()
        }

        Log.d("BrightcoveLayoutView", "Brightcove platform view created successfully")
    }

    private fun initializeVideo() {
        try {
            Log.d("BrightcoveLayoutView", "Initializing video...")

            val brightcoveVideoView = brightcoveVideoView ?: return

            // Extract parameters from creationParams
            val account = (creationParams?.get("accountId") as? String) 
                ?: (creationParams?.get("account") as? String) 
                ?: ""
            val policy = (creationParams?.get("policyKey") as? String)
                ?: (creationParams?.get("policy") as? String)
                ?: ""
            val videoId = creationParams?.get("videoId") as? String

            if (videoId.isNullOrEmpty()) {
                Log.e("BrightcoveLayoutView", "VideoId is null or empty")
                return
            }

            Log.d("BrightcoveLayoutView", "Using account: $account, videoId: $videoId")

            // Wait for the view to be properly initialized
            brightcoveVideoView.post {
                try {
                    val eventEmitter = brightcoveVideoView.getEventEmitter()
                    Log.d("BrightcoveLayoutView", "EventEmitter: $eventEmitter")

                    if (eventEmitter != null) {
                        // Set up event listeners for player state changes
                        setupEventListeners(eventEmitter)

                        val catalog = Catalog.Builder(eventEmitter, account)
                            .setBaseURL(Catalog.DEFAULT_EDGE_BASE_URL)
                            .setPolicy(policy)
                            .build()

                        catalog.findVideoByID(videoId, object : VideoListener() {
                            override fun onVideo(video: Video) {
                                Log.v("BrightcoveLayoutView", "onVideo: video = $video")
                                try {
                                    brightcoveVideoView.add(video)

                                    // Ensure audio volume is set before requesting focus
                                    val audioManager = audioManager
                                    if (audioManager != null) {
                                        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                                        val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                                        Log.d("BrightcoveLayoutView", "Audio volume check - current: $currentVolume, max: $maxVolume")
                                        if (currentVolume == 0) {
                                            val targetVolume = (maxVolume * 0.7).toInt()
                                            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, targetVolume, 0)
                                            Log.d("BrightcoveLayoutView", "Audio volume was 0, set to $targetVolume")
                                        }
                                    }

                                    // Request audio focus before starting playback
                                    requestAudioFocus()

                                    // Send video start event when video is loaded
                                    Companion.sendVideoStartEvent(viewId)

                                    // Start video playback automatically after a small delay to ensure audio focus
                                    brightcoveVideoView.postDelayed({
                                        brightcoveVideoView.start()
                                        Log.d("BrightcoveLayoutView", "Video playback started after initialization")
                                    }, 200)

                                    // Wait for video to be set before hiding controls
                                    brightcoveVideoView.post {
//                                        hideBrightcoveControls()
                                    }

                                    Log.d("BrightcoveLayoutView", "Brightcove video initialized successfully")
                                } catch (e: Exception) {
                                    Log.e("BrightcoveLayoutView", "Error adding/starting video: ${e.message}")
                                }
                            }
                        })
                    } else {
                        Log.e("BrightcoveLayoutView", "EventEmitter is null")
                    }
                } catch (e: Exception) {
                    Log.e("BrightcoveLayoutView", "Error in post block: ${e.message}")
                }
            }

            Log.d("BrightcoveLayoutView", "Video initialization started")
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error initializing video: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun setupEventListeners(eventEmitter: com.brightcove.player.event.EventEmitter) {
        try {
            // Listen for play events
            eventEmitter.on(EventType.PLAY) { event: Event ->
                Log.d("BrightcoveLayoutView", "PLAY event received")
                Companion.sendVideoPlayEvent(viewId)
            }

            // Listen for pause events
            eventEmitter.on(EventType.PAUSE) { event: Event ->
                Log.d("BrightcoveLayoutView", "PAUSE event received")
                Companion.sendVideoPauseEvent(viewId)
            }

            // Listen for video complete/end events
            eventEmitter.on(EventType.COMPLETED) { event: Event ->
                Log.d("BrightcoveLayoutView", "COMPLETED event received")
                Companion.sendVideoEndEvent(viewId)
            }

            // Listen for did play event (when playback actually starts)
            eventEmitter.on(EventType.DID_PLAY) { event: Event ->
                Log.d("BrightcoveLayoutView", "DID_PLAY event received")
                Companion.sendVideoPlayEvent(viewId)
            }

            // Listen for did pause event
            eventEmitter.on(EventType.DID_PAUSE) { event: Event ->
                Log.d("BrightcoveLayoutView", "DID_PAUSE event received")
                Companion.sendVideoPauseEvent(viewId)
            }

            Log.d("BrightcoveLayoutView", "Event listeners set up successfully")
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error setting up event listeners: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun hideBrightcoveControls() {
        try {
            Log.d("BrightcoveLayoutView", "Hiding Brightcove controls...")

            brightcoveVideoView?.let { videoView ->
                // Method 1: Set MediaController to null (most effective according to documentation)
                try {
                    videoView.setMediaController(null as android.widget.MediaController)
                    Log.d("BrightcoveLayoutView", "MediaController set to null successfully")
                } catch (e: Exception) {
                    Log.d("BrightcoveLayoutView", "setMediaController method failed: ${e.message}")
                }

                // Method 2: Use BrightcoveMediaController.hide() if available
                try {
                    val mediaController = videoView.getBrightcoveMediaController()
                    if (mediaController != null) {
                        mediaController.hide()
                        Log.d("BrightcoveLayoutView", "BrightcoveMediaController.hide() called successfully")
                    } else {
                        Log.d("BrightcoveLayoutView", "BrightcoveMediaController is null, will try again later")
                        // Try again after a delay
                        videoView.postDelayed({
                            try {
                                val delayedMediaController = videoView.getBrightcoveMediaController()
                                delayedMediaController?.hide()
                                Log.d("BrightcoveLayoutView", "Delayed BrightcoveMediaController.hide() called")
                            } catch (e: Exception) {
                                Log.d("BrightcoveLayoutView", "Delayed getBrightcoveMediaController failed: ${e.message}")
                            }
                        }, 1000) // Try again after 1 second
                    }
                } catch (e: Exception) {
                    Log.d("BrightcoveLayoutView", "getBrightcoveMediaController method failed: ${e.message}")
                }

                // Method 3: Use events to hide controls
                try {
                    val eventEmitter = videoView.getEventEmitter()
                    if (eventEmitter != null) {
                        eventEmitter.emit(HIDE_MEDIA_CONTROLS)
                        Log.d("BrightcoveLayoutView", "HIDE_MEDIA_CONTROLS event emitted successfully")
                    }
                } catch (e: Exception) {
                    Log.d("BrightcoveLayoutView", "Event emission method failed: ${e.message}")
                }

                // Method 4: Disable touch events to prevent control interaction
                videoView.setOnTouchListener { _, _ -> true }

                Log.d("BrightcoveLayoutView", "Brightcove controls hidden successfully")
            }
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error hiding controls: ${e.message}")
            e.printStackTrace()
        }
    }

    override fun getView(): View {
        return rootView
    }

    fun playVideo() {
        try {
            Log.d("BrightcoveLayoutView", "playVideo() called for viewId: $viewId")
            
            // Ensure audio volume is set
            val audioManager = audioManager
            if (audioManager != null) {
                val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                if (currentVolume == 0) {
                    val targetVolume = (maxVolume * 0.7).toInt()
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, targetVolume, 0)
                    Log.d("BrightcoveLayoutView", "Audio volume was 0, set to $targetVolume before playback")
                }
            }
            
            // Request audio focus BEFORE starting playback
            requestAudioFocus()
            
            // Small delay to ensure audio focus is granted
            brightcoveVideoView?.postDelayed({
                brightcoveVideoView?.start()
                Log.d("BrightcoveLayoutView", "Video playback started after audio focus request")
            }, 100)
            
            // Note: Event listener will send onVideoPlay event automatically
            Log.d("BrightcoveLayoutView", "Video play command executed successfully for viewId: $viewId")
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error playing video for viewId $viewId: ${e.message}")
            e.printStackTrace()
        }
    }

    fun pauseVideo() {
        try {
            Log.d("BrightcoveLayoutView", "pauseVideo() called for viewId: $viewId")
            brightcoveVideoView?.pause()
            // Note: Event listener will send onVideoPause event automatically
            Log.d("BrightcoveLayoutView", "Video pause command executed successfully for viewId: $viewId")
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error pausing video for viewId $viewId: ${e.message}")
        }
    }

    fun getVideoDuration(): Long {
        return try {
            brightcoveVideoView?.duration?.toLong() ?: 0L
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error getting video duration: ${e.message}")
            0L
        }
    }

    fun getCurrentPosition(): Long {
        return try {
            brightcoveVideoView?.currentPosition?.toLong() ?: 0L
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error getting current position: ${e.message}")
            0L
        }
    }

    fun seekToPosition(positionMs: Long) {
        try {
            Log.d("BrightcoveLayoutView", "seekToPosition() called for viewId: $viewId, position: ${positionMs}ms")
            brightcoveVideoView?.seekTo(positionMs.toInt())
            Log.d("BrightcoveLayoutView", "Video seek command executed successfully for viewId: $viewId")
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error seeking video for viewId $viewId: ${e.message}")
        }
    }

    private fun configureAudioAttributes(videoView: BrightcoveExoPlayerVideoView) {
        try {
            // Ensure audio is not muted and volume is set
            val audioManager = audioManager
            if (audioManager != null) {
                // Set volume to maximum for the music stream
                val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                Log.d("BrightcoveLayoutView", "Audio stream volume - current: $currentVolume, max: $maxVolume")
                
                // If volume is 0, set it to a reasonable level
                if (currentVolume == 0) {
                    val targetVolume = (maxVolume * 0.7).toInt() // 70% of max volume
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, targetVolume, 0)
                    Log.d("BrightcoveLayoutView", "Audio volume was 0, set to $targetVolume")
                }
            }
            
            // Try to access ExoPlayer instance if available
            try {
                // BrightcoveExoPlayerVideoView might expose ExoPlayer through reflection or getter
                // This is a fallback - Brightcove should handle this internally
                Log.d("BrightcoveLayoutView", "Audio configuration - Brightcove SDK will handle ExoPlayer audio")
            } catch (e: Exception) {
                Log.d("BrightcoveLayoutView", "Could not access ExoPlayer directly: ${e.message}")
            }
            
            Log.d("BrightcoveLayoutView", "Audio configuration completed")
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error configuring audio attributes: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun requestAudioFocus() {
        try {
            val audioManager = audioManager ?: return
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // Android 8.0+ requires AudioFocusRequest
                requestAudioFocusOreo(audioManager)
            } else {
                // For older Android versions
                val audioFocusChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
                    Log.d("BrightcoveLayoutView", "Audio focus changed (legacy): $focusChange")
                    when (focusChange) {
                        AudioManager.AUDIOFOCUS_LOSS, AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                            Log.d("BrightcoveLayoutView", "Audio focus lost (legacy) - pausing video")
                            brightcoveVideoView?.pause()
                        }
                        AudioManager.AUDIOFOCUS_GAIN -> {
                            Log.d("BrightcoveLayoutView", "Audio focus gained (legacy) - resuming video")
                            brightcoveVideoView?.start()
                        }
                    }
                }
                
                val result = audioManager.requestAudioFocus(
                    audioFocusChangeListener,
                    AudioManager.STREAM_MUSIC,
                    AudioManager.AUDIOFOCUS_GAIN
                )
                Log.d("BrightcoveLayoutView", "Audio focus request result (legacy): $result")
                if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                    Log.d("BrightcoveLayoutView", "✅ Audio focus requested and GRANTED (legacy)")
                } else {
                    Log.w("BrightcoveLayoutView", "❌ Audio focus request DENIED (legacy): $result")
                }
            }
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error requesting audio focus: ${e.message}")
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun requestAudioFocusOreo(audioManager: AudioManager) {
        try {
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MOVIE)
                .setFlags(AudioAttributes.FLAG_AUDIBILITY_ENFORCED)
                .build()
            
            audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(audioAttributes)
                .setAcceptsDelayedFocusGain(true)
                .setOnAudioFocusChangeListener { focusChange: Int ->
                    Log.d("BrightcoveLayoutView", "Audio focus changed: $focusChange")
                    when (focusChange) {
                        AudioManager.AUDIOFOCUS_LOSS, AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                            Log.d("BrightcoveLayoutView", "Audio focus lost - pausing video")
                            brightcoveVideoView?.pause()
                        }
                        AudioManager.AUDIOFOCUS_GAIN -> {
                            Log.d("BrightcoveLayoutView", "Audio focus gained - resuming video")
                            brightcoveVideoView?.start()
                        }
                        AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                            Log.d("BrightcoveLayoutView", "Audio focus ducking - lowering volume")
                            // Optionally lower volume here
                        }
                    }
                }
                .build()
            
            val result = audioManager.requestAudioFocus(audioFocusRequest!!)
            Log.d("BrightcoveLayoutView", "Audio focus request result: $result")
            if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                Log.d("BrightcoveLayoutView", "✅ Audio focus requested and GRANTED")
            } else {
                Log.w("BrightcoveLayoutView", "❌ Audio focus request DENIED or DELAYED: $result")
            }
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error requesting audio focus (Oreo+): ${e.message}")
            e.printStackTrace()
        }
    }

    private fun abandonAudioFocus() {
        try {
            val audioManager = audioManager ?: return
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                audioFocusRequest?.let {
                    audioManager.abandonAudioFocusRequest(it)
                    audioFocusRequest = null
                }
            } else {
                audioManager.abandonAudioFocus(null)
            }
            Log.d("BrightcoveLayoutView", "Audio focus abandoned")
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error abandoning audio focus: ${e.message}")
        }
    }

    override fun dispose() {
        try {
            // Abandon audio focus
            abandonAudioFocus()
            
            // Stop video playback before disposing
            brightcoveVideoView?.pause()

            // Remove from instances map
            viewInstances.remove(viewId)

            // Clear the video view
            brightcoveVideoView?.clear()

            Log.d("BrightcoveLayoutView", "View disposed and video stopped")
        } catch (e: Exception) {
            Log.e("BrightcoveLayoutView", "Error disposing view: ${e.message}")
        }
    }
}
