import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:scribe/views/screens/meeting_info/widgets/transcript_player.dart';

class TranscriptWidget extends StatefulWidget {
  final String transcript;
  final String audioUrl;
  const TranscriptWidget({
    super.key,
    required this.transcript,
    required this.audioUrl,
  });

  @override
  State<TranscriptWidget> createState() => _TranscriptWidgetState();
}

class _TranscriptWidgetState extends State<TranscriptWidget> {
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.stop);
    _initAudio();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  bool _audioLoaded = false;

  Future<void> _initAudio() async {
    if (_audioLoaded) return;
    final url = widget.audioUrl;
    if (url.isEmpty) return;
    try {
      // Use a 15 second timeout for setting the source to avoid the 30s TimeoutException
      await audioPlayer
          .setSource(UrlSource(url))
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Setting audio source timed out');
            },
          );
      _audioLoaded = true;
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to load audio: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.whiteColor,
            ),
            child: Column(
              spacing: 6,
              children: [
                TranscriptPlayer(audioPlayer: audioPlayer),

                Divider(),

                Text(
                  widget.transcript,
                  style: AppTextStyles.normalText.copyWith(
                    color: AppColors.blackColor,
                    wordSpacing: 2,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
