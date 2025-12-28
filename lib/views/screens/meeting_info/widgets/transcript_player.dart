import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';

class TranscriptPlayer extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const TranscriptPlayer({super.key, required this.audioPlayer});

  @override
  State<TranscriptPlayer> createState() => _TranscriptPlayerState();
}

class _TranscriptPlayerState extends State<TranscriptPlayer> {
  double? _dragValueMs;
  late StreamSubscription<void> _completeSub;
  late StreamSubscription<PlayerState> _playerStateSub;
  bool _isStarting = false;
  late StreamSubscription<Duration> _positionSub;
  Timer? _startTimeout;
  @override
  void didUpdateWidget(covariant TranscriptPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    // Listen for completion and reset to start
    _completeSub = widget.audioPlayer.onPlayerComplete.listen((_) async {
      try {
        await widget.audioPlayer.seek(Duration.zero);
        await widget.audioPlayer.pause();
        if (!mounted) return;
        setState(() {});
      } catch (_) {}
    });
    _playerStateSub = widget.audioPlayer.onPlayerStateChanged.listen((state) {
      if (_isStarting &&
          (state == PlayerState.paused || state == PlayerState.stopped)) {
        _startTimeout?.cancel();
        _isStarting = false;
      }
      if (!mounted) return;
      setState(() {});
    });
    _positionSub = widget.audioPlayer.onPositionChanged.listen((pos) {
      if (_isStarting && pos.inMilliseconds > 50) {
        _startTimeout?.cancel();
        _isStarting = false;
        if (!mounted) return;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use streams from AudioPlayer to derive position, duration, and state.
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(
          width: 1.5,
          color: AppColors.lightBlackColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Play / Pause button driven by player state stream.
          StreamBuilder<PlayerState>(
            stream: widget.audioPlayer.onPlayerStateChanged,
            builder: (context, stateSnap) {
              final playerState = stateSnap.data;
              final isPlaying = playerState == PlayerState.playing;
              // If we're in the middle of starting playback, show a spinner
              if (_isStarting) {
                return Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightBlackColor.withOpacity(0.1),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                );
              }
              return Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPlaying
                      ? Colors.blue.withOpacity(0.1)
                      : AppColors.lightBlackColor.withOpacity(0.05),
                  border: Border.all(
                    color: isPlaying
                        ? Colors.blue.withOpacity(0.3)
                        : AppColors.lightBlackColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: () async {
                      try {
                        if (isPlaying) {
                          await widget.audioPlayer.pause();
                        } else {
                          setState(() {
                            _isStarting = true;
                          });
                          _startTimeout?.cancel();
                          _startTimeout = Timer(const Duration(seconds: 8), () {
                            if (_isStarting) {
                              _isStarting = false;
                              if (mounted) setState(() {});
                            }
                          });
                          await widget.audioPlayer.resume();
                        }
                      } catch (_) {
                        if (mounted) {
                          setState(() {
                            _isStarting = false;
                          });
                        }
                      }
                    },
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 28,
                      color: isPlaying ? Colors.blue : AppColors.blackColor,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 16),

          // audio progress bar driven by duration and position streams
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<Duration?>(
                  stream: widget.audioPlayer.onDurationChanged,
                  builder: (context, durSnap) {
                    final dur = durSnap.data ?? Duration.zero;
                    final maxMs = (dur.inMilliseconds > 0)
                        ? dur.inMilliseconds.toDouble()
                        : 1.0;
                    return StreamBuilder<Duration>(
                      stream: widget.audioPlayer.onPositionChanged,
                      builder: (context, posSnap) {
                        final pos = posSnap.data ?? Duration.zero;
                        final valueMs =
                            (_dragValueMs ?? pos.inMilliseconds.toDouble())
                                .clamp(0.0, maxMs);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time labels above the slider
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _formatDuration(pos),
                                      style: AppTextStyles.normalText.copyWith(
                                        color: Colors.blue,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightBlackColor
                                          .withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _formatDuration(dur),
                                      style: AppTextStyles.normalText.copyWith(
                                        color: AppColors.blackColor.withOpacity(
                                          0.7,
                                        ),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Enhanced slider
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.blue,
                                inactiveTrackColor: Colors.grey.withOpacity(
                                  0.3,
                                ),
                                thumbColor: Colors.blue,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16,
                                ),
                                overlayColor: Colors.blue.withOpacity(0.1),
                                trackHeight: 4,
                                activeTickMarkColor: Colors.transparent,
                                inactiveTickMarkColor: Colors.transparent,
                              ),
                              child: Slider(
                                min: 0,
                                max: maxMs,
                                value: valueMs,
                                onChanged: (value) {
                                  setState(() {
                                    _dragValueMs = value;
                                  });
                                },
                                onChangeEnd: (value) async {
                                  final newPos = Duration(
                                    milliseconds: value.toInt(),
                                  );
                                  await widget.audioPlayer.seek(newPos);
                                  setState(() {
                                    _dragValueMs = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _completeSub.cancel();
    _playerStateSub.cancel();
    try {
      _positionSub.cancel();
    } catch (_) {}
    _startTimeout?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
