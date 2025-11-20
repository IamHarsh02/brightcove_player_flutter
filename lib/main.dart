import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'brightcove_player_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brightcove Player Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BrightcovePlayerScreen(),
    );
  }
}

class BrightcovePlayerScreen extends StatefulWidget {
  const BrightcovePlayerScreen({super.key});

  @override
  State<BrightcovePlayerScreen> createState() => _BrightcovePlayerScreenState();
}

class _BrightcovePlayerScreenState extends State<BrightcovePlayerScreen> {
  final GlobalKey<BrightcovePlayerWidgetState> _playerKey = GlobalKey();
  bool _isPlaying = false;
  bool _isLoading = true;
  Timer? _stateCheckTimer;

  @override
  void initState() {
    super.initState();
    // Start polling for player state as fallback
    _startStatePolling();
    // Set a timeout for loading state
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _stateCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatePolling() {
    _stateCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      if (!mounted || _playerKey.currentState == null) {
        return;
      }

      // Check if video is ready (has duration > 0)
      final duration = _playerKey.currentState!.videoDuration;
      if (duration.inMilliseconds > 0 && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }

      // Check current position to determine if playing
      // This is a fallback mechanism - callbacks should handle state primarily
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Brightcove Player'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Player Section
            Container(
              height: 250,
              color: Colors.black,
              child: Stack(
                children: [
                  BrightcovePlayerWidget(
                    key: _playerKey,
                    width: double.infinity,
                    height: 250,
                    accountId: 'Your Account ID',
                    policyKey: 'Your policyKey',
                    videoId: 'Your Video ID',
                    onVideoStart: () {
                      if (mounted) {
                        setState(() {
                          _isPlaying = true;
                          _isLoading = false;
                        });
                        debugPrint(
                          '✅ onVideoStart callback - isPlaying: true, isLoading: false',
                        );
                      }
                    },
                    onVideoPlay: () {
                      if (mounted) {
                        setState(() {
                          _isPlaying = true;
                          _isLoading = false;
                        });
                        debugPrint('▶️ onVideoPlay callback - isPlaying: true');
                      }
                    },
                    onVideoPause: () {
                      if (mounted) {
                        setState(() {
                          _isPlaying = false;
                        });
                        debugPrint(
                          '⏸️ onVideoPause callback - isPlaying: false',
                        );
                      }
                    },
                    onVideoEnd: () {
                      if (mounted) {
                        setState(() {
                          _isPlaying = false;
                        });
                        debugPrint('⏹️ onVideoEnd callback - isPlaying: false');
                      }
                    },
                  ),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              ),
            ),

            // Controls Section
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video Controls',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Play/Pause Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_isPlaying) {
                            await _playerKey.currentState?.pause();
                          } else {
                            await _playerKey.currentState?.play();
                          }
                        },
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        label: Text(_isPlaying ? 'Pause' : 'Play'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),

                      // Seek Backward Button
                      IconButton(
                        onPressed: () async {
                          final currentPos =
                              _playerKey.currentState?.currentPosition ??
                              Duration.zero;
                          final newPos = Duration(
                            milliseconds: (currentPos.inMilliseconds - 10000)
                                .clamp(0, double.infinity)
                                .toInt(),
                          );
                          await _playerKey.currentState?.seekTo(newPos);
                        },
                        icon: const Icon(Icons.replay_10),
                        tooltip: 'Rewind 10s',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.all(12),
                        ),
                      ),

                      // Seek Forward Button
                      IconButton(
                        onPressed: () async {
                          final currentPos =
                              _playerKey.currentState?.currentPosition ??
                              Duration.zero;
                          final duration =
                              _playerKey.currentState?.videoDuration ??
                              Duration.zero;
                          final newPos = Duration(
                            milliseconds: (currentPos.inMilliseconds + 10000)
                                .clamp(0, duration.inMilliseconds)
                                .toInt(),
                          );
                          await _playerKey.currentState?.seekTo(newPos);
                        },
                        icon: const Icon(Icons.forward_10),
                        tooltip: 'Forward 10s',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Video Progress Section
                  const Text(
                    'Video Progress',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  _VideoProgressWidget(playerKey: _playerKey),

                  const SizedBox(height: 24),

                  // Video Information Section
                  const Text(
                    'Video Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(label: 'Account ID', value: 'Your Account ID'),
                          const Divider(),
                          _InfoRow(label: 'Video ID', value: 'Your Video ID'),
                          const Divider(),
                          _InfoRow(
                            label: 'Status',
                            value: _isPlaying ? 'Playing' : 'Paused',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoProgressWidget extends StatefulWidget {
  final GlobalKey<BrightcovePlayerWidgetState> playerKey;

  const _VideoProgressWidget({required this.playerKey});

  @override
  State<_VideoProgressWidget> createState() => _VideoProgressWidgetState();
}

class _VideoProgressWidgetState extends State<_VideoProgressWidget> {
  Duration _currentPosition = Duration.zero;
  Duration _videoDuration = Duration.zero;
  bool _isDragging = false;
  double? _dragValue;

  @override
  void initState() {
    super.initState();
    _updateProgress();
  }

  void _updateProgress() {
    if (widget.playerKey.currentState != null) {
      setState(() {
        _currentPosition = widget.playerKey.currentState!.currentPosition;
        _videoDuration = widget.playerKey.currentState!.videoDuration;
      });
    }
    Future.delayed(const Duration(milliseconds: 100), _updateProgress);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = _isDragging && _dragValue != null
        ? Duration(
            milliseconds: (_dragValue! * _videoDuration.inMilliseconds).toInt(),
          )
        : _currentPosition;

    final progress = _videoDuration.inMilliseconds > 0
        ? position.inMilliseconds / _videoDuration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        Slider(
          value: _isDragging && _dragValue != null
              ? _dragValue!.clamp(0.0, 1.0)
              : progress.clamp(0.0, 1.0),
          onChanged: (value) {
            setState(() {
              _isDragging = true;
              _dragValue = value;
            });
          },
          onChangeEnd: (value) async {
            setState(() {
              _isDragging = false;
            });
            final seekPosition = Duration(
              milliseconds: (value * _videoDuration.inMilliseconds).toInt(),
            );
            await widget.playerKey.currentState?.seekTo(seekPosition);
            _dragValue = null;
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                _formatDuration(_videoDuration),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
