import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:scribe/core/user_feedback/user_feedback.dart';
import 'package:scribe/providers/meeting_provider.dart';
import 'package:scribe/views/screens/record/widgets/recording_actions_button.dart';
import 'package:scribe/models/meeting_model.dart';
import 'package:scribe/controllers/meeting_controller.dart';
import 'package:scribe/controllers/recording_controller.dart';
import 'package:scribe/core/services/ai_service.dart';
import 'package:scribe/core/services/speech_service.dart';
import 'package:scribe/models/todo_model.dart';

class RecordScreen extends ConsumerStatefulWidget {
  final ValueChanged<bool>? onRecordingStateChanged;
  final RecordingController recordingController;
  final VoidCallback? onNavigateToHome;

  const RecordScreen({
    super.key,
    this.onRecordingStateChanged,
    required this.recordingController,
    this.onNavigateToHome,
  });

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  bool isRecording = true;
  bool isPaused = false;
  bool isSaving = false;
  String? selectedLanguage;
  bool autoDetectLanguage = true;

  // Timer-related variables
  Timer? _timer;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    try {
      if (!isSaving && widget.recordingController.isRecordingActive) {
        // Fire-and-forget; dispose must be fast
        widget.recordingController.dismissRecording();
      }
    } catch (_) {
      // no-op: best-effort cleanup
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused && mounted) {
        setState(() {
          _recordingDuration = Duration(
            seconds: _recordingDuration.inSeconds + 1,
          );
        });

        // Show warning at 18 minutes (2 minutes before limit)
        if (_recordingDuration.inSeconds == 1080) {
          // 18 minutes
          if (mounted) {
            UserFeedback.showInfoSnackbar(
              context,
              '⚠️ Approaching 20 minute limit. Consider saving soon.',
            );
          }
        }

        // Show critical warning at 19.5 minutes
        if (_recordingDuration.inSeconds == 1170) {
          // 19.5 minutes
          if (mounted) {
            UserFeedback.showInfoSnackbar(
              context,
              '⚠️ SAVE NOW! Recording will reach 20 minute limit soon.',
            );
          }
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _pauseOrResume() async {
    await widget.recordingController.pauseRecording();
    if (mounted) {
      setState(() {
        isPaused = widget.recordingController.isRecordingPaused;
      });
    }
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    await widget.recordingController.dismissRecording();
    if (mounted) {
      setState(() {
        isRecording = false;
        isPaused = false;
      });
    }
    widget.onRecordingStateChanged?.call(false);
    widget.onNavigateToHome?.call();
  }

  // save the meeting in firestore database
  Future<void> _save() async {
    _timer?.cancel();
    if (_recordingDuration.inSeconds > 60) {
      debugPrint(
        'INFO: Recording duration (${_formatDuration(_recordingDuration)}) exceeds 60 seconds. Audio will be saved but automatic transcription may not be available.',
      );
    }

    // Block recordings over 20 minutes
    if (_recordingDuration.inSeconds > 1200) {
      if (mounted) {
        UserFeedback.showInfoSnackbar(
          context,
          'Recording is too long (${_formatDuration(_recordingDuration)}). Maximum duration is 20 minutes. Please record shorter segments.',
        );
        _startTimer();
      }
      return;
    }

    if (mounted) {
      setState(() {
        isSaving = true;
      });
    }
    final processingNotifier = ref.read(meetingProcessingProvider.notifier);
    processingNotifier.state = true;
    // mark recording state and navigate immediately so Home shows the processing indicator
    widget.onRecordingStateChanged?.call(false);
    widget.onNavigateToHome?.call();

    try {
      // Get recording result with URL, transcript, and detected language
      final recordingResult = await widget.recordingController.saveRecording(
        language: selectedLanguage,
        autoDetectLanguage: autoDetectLanguage,
      );
      final url = recordingResult['url'];
      final transcript = recordingResult['transcript'];
      final detectedLanguage = recordingResult['detectedLanguage'];
      final error = recordingResult['error'];

      debugPrint('Recording result - URL: ${url != null ? "✓" : "✗"}');
      debugPrint(
        'Recording result - Transcript: ${transcript != null ? transcript.substring(0, transcript.length > 50 ? 50 : transcript.length) : "✗ NULL"}',
      );
      debugPrint('Recording result - Error: ${error ?? "None"}');

      // Check for transcription error
      if (error != null) {
        debugPrint('Transcription error occurred: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Warning: Transcription failed - $error'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }

      // Log language detection results
      if (detectedLanguage != null) {
        debugPrint(
          'Language detected: ${SpeechService.getLanguageName(detectedLanguage)} ($detectedLanguage)',
        );
      }

      // Process transcript with AI if available
      String processedTitle = 'Meeting Recording';
      String processedDescription = 'Meeting recorded successfully';
      String processedSummary = transcript ?? 'No transcript available';
      List<TodoModel> processedTodos = [];

      if (transcript != null && transcript.trim().isNotEmpty) {
        debugPrint(
          'Processing transcript with AI (${transcript.length} chars)...',
        );
        try {
          final aiService = AiService();
          final aiResult = await aiService.processTranscript(
            transcript,
            'Meeting Recording',
            detectedLanguage: detectedLanguage,
          );

          debugPrint('AI processing completed successfully');

          // Extract processed data from AI result
          processedTitle = aiResult['title'] ?? processedTitle;
          processedDescription =
              aiResult['description'] ?? processedDescription;
          processedSummary = aiResult['summary'] ?? processedSummary;

          debugPrint('AI Title: $processedTitle');
          debugPrint('AI Description: $processedDescription');
          debugPrint('AI Summary length: ${processedSummary.length} chars');

          // Convert AI todos to TodoModel objects
          if (aiResult['toDo'] is List) {
            final aiTodos = aiResult['toDo'] as List;
            processedTodos = aiTodos.map<TodoModel>((todo) {
              return TodoModel(
                todoId: todo['todoId'] ?? '',
                meetingId: '', // Will be set after meeting is saved
                title: todo['title'] ?? '',
                isCompleted: todo['isCompleted'] ?? false,
                priority: todo['priority'] ?? 'medium',
              );
            }).toList();
            debugPrint('AI Todos extracted: ${processedTodos.length}');
          }
        } catch (e, stackTrace) {
          debugPrint('AI processing failed: $e');
          debugPrint('Stack trace: $stackTrace');
          // Continue with transcript as summary if AI fails
          processedSummary = transcript;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Warning: AI processing failed, using raw transcript',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        debugPrint('No transcript available for AI processing');
      }

      // Create MeetingModel with processed data
      final meeting = MeetingModel(
        meetingId: '',
        ownerId: FirebaseAuth.instance.currentUser!.uid,
        title: processedTitle,
        description: processedDescription,
        createdAt: DateTime.now(),
        duration: _recordingDuration,
        summary: processedSummary,
        toDo: processedTodos,
        audioFilePath: url ?? '',
        fullTranscript: transcript ?? '',
      );

      // Save to Firestore
      final meetingController = MeetingController();
      debugPrint(meeting.toMap().toString());
      final savedMeetingId = await meetingController.saveMeetingInFirestore(
        meeting,
      );

      if (savedMeetingId != null) {
        debugPrint('Meeting saved successfully with ID: $savedMeetingId');
      } else {
        debugPrint('Failed to save meeting to Firestore');
      }

      widget.onNavigateToHome?.call();
    } catch (e) {
      debugPrint('Error saving meeting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save meeting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      processingNotifier.state = false;

      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: Text('RECORDER')),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Divider(),
                SizedBox(height: 60),

                // Duration Text
                Text(
                  _formatDuration(_recordingDuration),
                  style: AppTextStyles.h1.copyWith(
                    fontFamily: "monospace",
                    letterSpacing: 2,
                  ),
                ),

                Spacer(),

                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isRecording
                        ? RecordingActionsButton(
                            isRecording: isRecording,
                            isPaused: isPaused,
                            onPressed: isSaving ? null : _pauseOrResume,
                            onDismiss: isSaving ? null : _dismiss,
                            onSave: isSaving ? null : _save,
                          )
                        : SizedBox(),
                  ],
                ),

                SizedBox(height: mq.height * 0.20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
