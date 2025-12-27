import 'package:record/record.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:scribe/core/services/speech_service.dart';
import 'package:flutter/foundation.dart';

class RecordingController {
  final AudioRecorder _recorder = AudioRecorder();
  final SpeechService _speechService = SpeechService();
  String? _filePath;
  bool isRecording = false;
  bool isPaused = false;
  String? _lastError;

  Future<void> startRecording() async {
    // Check permissions and encoder support first
    final hasPermission = await _recorder.hasPermission();
    final isEncoderSupported = await _recorder.isEncoderSupported(
      AudioEncoder.wav,
    );

    debugPrint('Recording capabilities check:');
    debugPrint('  - Has permission: $hasPermission');
    debugPrint('  - WAV encoder supported: $isEncoderSupported');

    if (!hasPermission) {
      debugPrint('ERROR: No microphone permission!');
      // Don't throw here to avoid crashing the app when permission is denied.
      // Instead record the error and return gracefully so callers can decide
      // how to inform the user.
      _lastError = 'Microphone permission required for recording';
      isRecording = false;
      isPaused = false;
      return;
    }

    if (!isEncoderSupported) {
      debugPrint('WARNING: WAV encoder not supported, falling back to default');
    }

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/audio_${const Uuid().v4()}.wav';
    _filePath = filePath;

    debugPrint('Recording to: $filePath');

    // Use WAV format with LINEAR16 encoding for best compatibility with Google Speech API
    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          bitRate: 128000,
          numChannels: 1, // Mono for speech recognition
        ),
        path: filePath,
      );

      debugPrint('Recording started: $filePath (WAV format, 16kHz, mono)');
      isRecording = true;
      isPaused = false;
      _lastError = null;
    } catch (e, st) {
      debugPrint('RecordingController: Failed to start recording: $e');
      debugPrint('Stack trace: $st');
      _lastError = e.toString();
      isRecording = false;
      isPaused = false;
      return;
    }
  }

  Future<void> pauseRecording() async {
    if (isRecording && !isPaused) {
      try {
        await _recorder.pause();
        isPaused = true;
      } catch (e, st) {
        debugPrint('RecordingController: Failed to pause recording: $e');
        debugPrint('Stack trace: $st');
        _lastError = e.toString();
      }
    } else if (isRecording && isPaused) {
      try {
        await _recorder.resume();
        isPaused = false;
      } catch (e, st) {
        debugPrint('RecordingController: Failed to resume recording: $e');
        debugPrint('Stack trace: $st');
        _lastError = e.toString();
      }
    }
  }

  Future<Map<String, String?>> saveRecording({
    String? language,
    bool autoDetectLanguage = true,
  }) async {
    if (_filePath == null) {
      debugPrint('RecordingController: No file path available');
      return {
        'url': null,
        'transcript': null,
        'detectedLanguage': null,
        'error': 'No recording file path',
      };
    }

    try {
      await _recorder.stop();
    } catch (e, st) {
      debugPrint('RecordingController: Warning - stop() threw: $e');
      debugPrint('Stack trace: $st');
      _lastError = e.toString();
    }
    isRecording = false;
    isPaused = false;

    final file = File(_filePath!);
    if (!file.existsSync()) {
      debugPrint('RecordingController: File does not exist at $_filePath');
      return {
        'url': null,
        'transcript': null,
        'detectedLanguage': null,
        'error': 'Recording file not found',
      };
    }

    // Additional validation for the audio file
    final fileSize = file.lengthSync();
    debugPrint('RecordingController: File exists with size: $fileSize bytes');

    if (fileSize == 0) {
      debugPrint('RecordingController: ERROR - File is empty!');
      return {
        'url': null,
        'transcript': null,
        'detectedLanguage': null,
        'error':
            'Recording failed - audio file is empty. Check microphone permissions.',
      };
    }

    if (fileSize < 44) {
      debugPrint(
        'RecordingController: ERROR - File too small ($fileSize bytes)',
      );
      return {
        'url': null,
        'transcript': null,
        'detectedLanguage': null,
        'error': 'Recording failed - audio file is corrupted or too small.',
      };
    }

    debugPrint('RecordingController: Processing recording at $_filePath');

    // Transcribe the audio file locally before uploading with language support
    final transcriptionResult = await _speechService.transcribeAudio(
      _filePath!,
      language: language,
      autoDetect: autoDetectLanguage,
    );

    final transcript = transcriptionResult['transcript'];
    final detectedLanguage = transcriptionResult['detectedLanguage'];
    final transcriptionError = transcriptionResult['error'];

    debugPrint('RecordingController: Transcription completed');
    debugPrint('  - Transcript length: ${transcript?.length ?? 0}');
    debugPrint('  - Detected language: $detectedLanguage');
    debugPrint('  - Error: $transcriptionError');

    // Upload to Firebase Storage
    try {
      debugPrint('RecordingController: Uploading to Firebase Storage...');

      // Get file extension for storage
      final fileExtension = _filePath!.split('.').last;

      final storageRef = FirebaseStorage.instance.ref().child(
        'recordings/${const Uuid().v4()}.$fileExtension',
      );
      await storageRef.putFile(file);
      final url = await storageRef.getDownloadURL();
      debugPrint('RecordingController: Upload successful - $url');

      // Clean up local file
      if (file.existsSync()) {
        await file.delete();
        debugPrint('RecordingController: Local file cleaned up');
      }

      return {
        'url': url,
        'transcript': transcript,
        'detectedLanguage': detectedLanguage,
        'error': transcriptionError,
      };
    } catch (e, stackTrace) {
      debugPrint('RecordingController: Upload failed - $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'url': null,
        'transcript': transcript,
        'detectedLanguage': detectedLanguage,
        'error': transcriptionError ?? 'Upload failed: $e',
      };
    }
  }

  Future<void> dismissRecording() async {
    try {
      await _recorder.stop();
    } catch (e, st) {
      debugPrint(
        'RecordingController: Warning - stop() threw during dismiss: $e',
      );
      debugPrint('Stack trace: $st');
      _lastError = e.toString();
    }
    isRecording = false;
    isPaused = false;

    // Clean up local file if it exists
    if (_filePath != null) {
      final file = File(_filePath!);
      if (file.existsSync()) {
        await file.delete();
      }
    }

    _filePath = null;
  }

  bool get isRecordingActive => isRecording;
  bool get isRecordingPaused => isPaused;

  /// Last non-fatal error message (if any). Use to show user-friendly errors
  /// without crashing the app.
  String? get lastError => _lastError;

  /// Test method to verify recording and transcription capabilities
  Future<Map<String, dynamic>> testRecordingCapabilities() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      final isWavSupported = await _recorder.isEncoderSupported(
        AudioEncoder.wav,
      );
      final isM4aSupported = await _recorder.isEncoderSupported(
        AudioEncoder.aacLc,
      );

      // Test SpeechService initialization
      bool speechServiceInitialized = false;
      String? speechServiceError;
      try {
        await _speechService.initialize();
        speechServiceInitialized = true;
      } catch (e) {
        speechServiceError = e.toString();
      }

      return {
        'hasPermission': hasPermission,
        'wavSupported': isWavSupported,
        'm4aSupported': isM4aSupported,
        'speechServiceInitialized': speechServiceInitialized,
        'speechServiceError': speechServiceError,
        'tempDirectory': (await getTemporaryDirectory()).path,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}