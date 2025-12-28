import 'package:flutter/material.dart';
import 'package:scribe/core/services/tts_service.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:scribe/views/widgets/primary_button_with_icon.dart';

class SummaryWidget extends StatefulWidget {
  final String summary;
  const SummaryWidget({super.key, required this.summary});

  @override
  State<SummaryWidget> createState() => _SummaryWidgetState();
}

class _SummaryWidgetState extends State<SummaryWidget> {
  final TtsService _ttsService = TtsService();
  bool isReading = false;
  bool canResume = false;
  int? _currentWordStart, _currentWordEnd;

  void _initTts() async {
    // Set up progress callback
    _ttsService.onProgressUpdate = (start, end) {
      setState(() {
        _currentWordStart = start;
        _currentWordEnd = end;
      });
    };

    // Set up start callback
    _ttsService.onStart = () {
      setState(() {
        isReading = true;
      });
    };

    // Set up completion callback
    _ttsService.onComplete = () {
      setState(() {
        isReading = false;
        canResume = _ttsService.canResume;
        _currentWordStart = null;
        _currentWordEnd = null;
      });
    };

    // Initialize the TTS service
    await _ttsService.initTts();
  }

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.whiteColor,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PrimaryButtonWithIcon(
                      text: isReading
                          ? "Stop Reading"
                          : canResume
                          ? "Resume Reading"
                          : "Read Aloud",
                      icon: isReading
                          ? Icons.stop
                          : canResume
                          ? Icons.play_arrow
                          : Icons.record_voice_over,
                      foregroundColor: AppColors.whiteColor,
                      backgroundColor: isReading
                          ? AppColors.redColor
                          : AppColors.iconButtonColor,
                      onTap: () async {
                        if (isReading) {
                          await _ttsService.stop();
                          setState(() {
                            isReading = false;
                            canResume = _ttsService.canResume;
                          });
                        } else {
                          setState(() {
                            canResume =
                                false; // Reset resume state when starting/resuming
                          });
                          await _ttsService.speak(widget.summary);
                        }
                      },
                    ),
                    if (canResume && !isReading) ...[
                      SizedBox(width: 8),
                      PrimaryButtonWithIcon(
                        text: "Start Over",
                        icon: Icons.restart_alt,
                        foregroundColor: AppColors.whiteColor,
                        backgroundColor: AppColors.iconButtonColor,
                        onTap: () async {
                          await _ttsService.reset();
                          setState(() {
                            canResume = false;
                            _currentWordStart = null;
                            _currentWordEnd = null;
                          });
                          await _ttsService.speak(widget.summary);
                        },
                      ),
                    ],
                  ],
                ),
                Divider(),
                SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _currentWordStart != null
                            ? widget.summary.substring(0, _currentWordStart)
                            : widget.summary,
                        style: AppTextStyles.normalText.copyWith(
                          color: AppColors.blackColor,
                          wordSpacing: 2,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                      if (_currentWordStart != null && _currentWordEnd != null)
                        TextSpan(
                          text: widget.summary.substring(
                            _currentWordStart!,
                            _currentWordEnd!,
                          ),
                          style: AppTextStyles.normalText.copyWith(
                            color: AppColors.whiteColor,
                            wordSpacing: 2,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            backgroundColor: AppColors.iconButtonColor,
                          ),
                        ),
                      if (_currentWordEnd != null)
                        TextSpan(
                          text: widget.summary.substring(_currentWordEnd!),
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
          ),
        ],
      ),
    );
  }
}
