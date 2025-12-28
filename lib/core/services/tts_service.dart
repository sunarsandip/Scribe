import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  Map? currentVoice;
  bool _isReading = false;
  String? _currentText;
  int _currentPosition = 0;
  int _resumeOffset = 0;
  bool _wasStopped = false;

  // Callbacks for progress updates
  Function(int start, int end)? onProgressUpdate;
  Function()? onStart;
  Function()? onComplete;

  bool get isReading => _isReading;
  bool get canResume =>
      _wasStopped && _currentText != null && _currentPosition >= 0;

  Future<void> initTts() async {
    try {
      // Set up progress handler
      _flutterTts.setProgressHandler((text, start, end, word) {
        // Adjust position based on resume offset
        int adjustedStart = start + _resumeOffset;
        int adjustedEnd = end + _resumeOffset;
        _currentPosition = adjustedStart;

        if (onProgressUpdate != null) {
          onProgressUpdate!(adjustedStart, adjustedEnd);
        }
      });

      // Set up completion handler
      _flutterTts.setCompletionHandler(() {
        _isReading = false;
        // Only reset position if reading completed naturally (not stopped by user)
        if (!_wasStopped) {
          _currentPosition = 0;
          _resumeOffset = 0;
        }
        if (onComplete != null) {
          onComplete!();
        }
      });

      // Set up start handler
      _flutterTts.setStartHandler(() {
        _isReading = true;
        if (onStart != null) {
          onStart!();
        }
      });

      // Get available voices
      final voices = await _flutterTts.getVoices;
      List<Map> voiceList = List<Map>.from(voices);
      voiceList = voiceList
          .where((voice) => voice['name'].contains("en"))
          .toList();

      if (voiceList.isNotEmpty) {
        currentVoice = voiceList.first;
        await setVoice(currentVoice!);
      }
    } catch (e) {
      debugPrint("Failed to initialize TTS: $e");
    }
  }

  Future<void> setVoice(Map voice) async {
    try {
      await _flutterTts.setVoice({
        "name": voice["name"],
        "locale": voice["locale"],
      });
      currentVoice = voice;
    } catch (e) {
      debugPrint("Failed to set voice: $e");
    }
  }

  Future<void> speak(String text) async {
    try {
      if (_isReading) {
        await stop();
      }

      String? previousText = _currentText;
      _currentText = text;
      String textToSpeak;

      // If we can resume and it's the same text, resume from current position
      if (_wasStopped && previousText == text && _currentPosition > 0) {
        textToSpeak = text.substring(_currentPosition);
        _resumeOffset = _currentPosition;
        _wasStopped = false;
        debugPrint("Resuming from position: $_currentPosition");
      } else {
        // Start from beginning
        textToSpeak = text;
        _currentPosition = 0;
        _resumeOffset = 0;
        _wasStopped = false;
        debugPrint("Starting from beginning");
      }

      await _flutterTts.speak(textToSpeak);
    } catch (e) {
      debugPrint("Failed to speak: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isReading = false;
      _wasStopped = true;
      debugPrint(
        "TTS stopped. Position: $_currentPosition, Can resume: $canResume",
      );
    } catch (e) {
      debugPrint("Failed to stop TTS: $e");
    }
  }

  Future<void> reset() async {
    try {
      await _flutterTts.stop();
      _isReading = false;
      _wasStopped = false;
      _currentPosition = 0;
      _resumeOffset = 0;
      _currentText = null;
    } catch (e) {
      debugPrint("Failed to reset TTS: $e");
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      debugPrint("Failed to pause TTS: $e");
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}