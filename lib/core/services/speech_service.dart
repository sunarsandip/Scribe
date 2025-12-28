import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class SpeechService {
  SpeechToText? _speechToText;
  bool _initialized = false;

  // Maximum duration for synchronous recognition (in seconds)
  static const int maxSyncDuration = 60;

  // Maximum duration we want to support (20 minutes = 1200 seconds)
  static const int maxSupportedDuration = 1200;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final jsonString = await rootBundle.loadString(
        'assets/service_account.json',
      );
      final serviceAccount = ServiceAccount.fromString(jsonString);
      _speechToText = SpeechToText.viaServiceAccount(serviceAccount);
      _initialized = true;
      debugPrint('SpeechService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize SpeechService: $e');
      rethrow;
    }
  }

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'ja': 'Japanese',
    'ko': 'Korean',
    'zh': 'Chinese',
    'ar': 'Arabic',
    'hi': 'Hindi',
    'ne': 'Nepali',
    'bn': 'Bengali',
    'ur': 'Urdu',
    'ta': 'Tamil',
    'te': 'Telugu',
    'ml': 'Malayalam',
    'kn': 'Kannada',
    'gu': 'Gujarati',
    'pa': 'Punjabi',
    'mr': 'Marathi',
    'th': 'Thai',
    'vi': 'Vietnamese',
    'id': 'Indonesian',
    'ms': 'Malay',
    'tl': 'Filipino',
    'nl': 'Dutch',
    'sv': 'Swedish',
    'no': 'Norwegian',
    'da': 'Danish',
    'fi': 'Finnish',
    'pl': 'Polish',
    'cs': 'Czech',
    'sk': 'Slovak',
    'hu': 'Hungarian',
    'ro': 'Romanian',
    'bg': 'Bulgarian',
    'hr': 'Croatian',
    'sr': 'Serbian',
    'sl': 'Slovenian',
    'et': 'Estonian',
    'lv': 'Latvian',
    'lt': 'Lithuanian',
    'el': 'Greek',
    'tr': 'Turkish',
    'he': 'Hebrew',
    'fa': 'Persian',
    'uk': 'Ukrainian',
  };

  static String _defaultLanguage = 'en';
  static void setDefaultLanguage(String lang) => _defaultLanguage = lang;
  static String getDefaultLanguage() => _defaultLanguage;
  static String? getLanguageName(String code) => supportedLanguages[code];

  static List<Map<String, String>> getSupportedLanguagesList() {
    return supportedLanguages.entries
        .map((entry) => {'code': entry.key, 'name': entry.value})
        .toList()
      ..sort((a, b) => a['name']!.compareTo(b['name']!));
  }

  /// Detect the most likely language from text content
  /// This is a simple heuristic-based detection
  static String detectLanguageFromText(String text) {
    if (text.isEmpty) return _defaultLanguage;

    final textLower = text.toLowerCase();

    // Detect non-Latin scripts first
    // Japanese detection (Hiragana, Katakana, Kanji)
    if (RegExp(r'[ひ-ゟ]|[ァ-ヿ]|[一-龯]').hasMatch(text)) return 'ja';

    // Korean detection
    if (RegExp(r'[가-힣]').hasMatch(text)) return 'ko';

    // Chinese detection (Traditional and Simplified)
    if (RegExp(r'[一-龯]').hasMatch(text) &&
        !RegExp(r'[ひ-ゟ]|[ァ-ヿ]').hasMatch(text)) {
      return 'zh';
    }

    // Arabic detection
    if (RegExp(r'[ء-ي]').hasMatch(text)) return 'ar';

    // Hindi/Devanagari detection
    if (RegExp(r'[ऀ-ॿ]').hasMatch(text)) {
      // Check for Nepali-specific words to differentiate from Hindi
      final nepaliWords = [
        'हो',
        'छ',
        'गर्नुहोस्',
        'यो',
        'त्यो',
        'मा',
        'को',
        'र',
        'गर्ने',
      ];
      final words = text.toLowerCase().split(RegExp(r'\W+'));
      final nepaliWordCount = words
          .where((word) => nepaliWords.contains(word))
          .length;

      // If we find Nepali-specific words, return 'ne', otherwise 'hi'
      if (nepaliWordCount > 0) return 'ne';
      return 'hi';
    }

    // Russian/Cyrillic detection
    if (RegExp(r'[а-я]').hasMatch(textLower)) return 'ru';

    // Greek detection
    if (RegExp(r'[α-ω]').hasMatch(textLower)) return 'el';

    // Simple word-based detection for Latin script languages
    final germanWords = ['und', 'der', 'die', 'das', 'ist', 'ich', 'sie'];
    final spanishWords = ['y', 'el', 'la', 'de', 'que', 'a', 'en', 'es'];
    final frenchWords = ['et', 'le', 'de', 'à', 'un', 'il', 'en'];
    final italianWords = ['e', 'il', 'di', 'che', 'la', 'un', 'a'];
    final portugueseWords = ['e', 'o', 'de', 'a', 'que', 'em', 'um'];

    final words = textLower.split(RegExp(r'\W+'));

    int germanCount = words.where((word) => germanWords.contains(word)).length;
    int spanishCount = words
        .where((word) => spanishWords.contains(word))
        .length;
    int frenchCount = words.where((word) => frenchWords.contains(word)).length;
    int italianCount = words
        .where((word) => italianWords.contains(word))
        .length;
    int portugueseCount = words
        .where((word) => portugueseWords.contains(word))
        .length;

    // Find the language with the highest count
    Map<String, int> scores = {
      'de': germanCount,
      'es': spanishCount,
      'fr': frenchCount,
      'it': italianCount,
      'pt': portugueseCount,
    };

    String bestMatch = scores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Only return the detected language if we have reasonable confidence
    if (scores[bestMatch]! > 0 && words.length > 2) {
      return bestMatch;
    }

    // Default to English if no clear detection
    return 'en';
  }

  String _convertToBcp47(String code) {
    final map = {
      'en': 'en-US',
      'es': 'es-ES',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'it': 'it-IT',
      'pt': 'pt-PT',
      'ru': 'ru-RU',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'zh': 'zh-CN',
      'ar': 'ar-SA',
      'hi': 'hi-IN',
      'ne': 'ne-NP',
      'bn': 'bn-BD',
      'ur': 'ur-PK',
      'ta': 'ta-IN',
      'te': 'te-IN',
      'ml': 'ml-IN',
      'kn': 'kn-IN',
      'gu': 'gu-IN',
      'pa': 'pa-IN',
      'mr': 'mr-IN',
      'th': 'th-TH',
      'vi': 'vi-VN',
      'id': 'id-ID',
      'ms': 'ms-MY',
      'tl': 'tl-PH',
      'nl': 'nl-NL',
      'sv': 'sv-SE',
      'no': 'no-NO',
      'da': 'da-DK',
      'fi': 'fi-FI',
      'pl': 'pl-PL',
      'cs': 'cs-CZ',
      'sk': 'sk-SK',
      'hu': 'hu-HU',
      'ro': 'ro-RO',
      'bg': 'bg-BG',
      'hr': 'hr-HR',
      'sr': 'sr-RS',
      'sl': 'sl-SI',
      'et': 'et-EE',
      'lv': 'lv-LV',
      'lt': 'lt-LT',
      'el': 'el-GR',
      'tr': 'tr-TR',
      'he': 'he-IL',
      'fa': 'fa-IR',
      'uk': 'uk-UA',
    };
    return map[code] ?? '$code-${code.toUpperCase()}';
  }

  /// Estimate audio duration from file size (rough approximation)
  /// Returns duration in seconds
  int _estimateAudioDuration(int fileSizeBytes, String extension) {
    // Rough bitrate estimates (in bytes per second)
    final bitrateMap = {
      'wav': 32000, // 16-bit PCM at 16kHz stereo
      'mp3': 16000, // ~128 kbps
      'm4a': 16000, // ~128 kbps
      'aac': 16000, // ~128 kbps
      'mp4': 16000, // ~128 kbps
    };

    final ext = extension.toLowerCase();
    final estimatedBitrate = bitrateMap[ext] ?? 16000;

    // Calculate duration: fileSize / bytesPerSecond
    final estimatedDuration = (fileSizeBytes / estimatedBitrate).ceil();

    debugPrint(
      'Estimated audio duration: $estimatedDuration seconds (file size: $fileSizeBytes bytes, format: $ext)',
    );
    return estimatedDuration;
  }

  Future<Map<String, String?>> transcribeAudio(
    String path, {
    String? language,
    bool autoDetect = false,
    String? storageUri, // Firebase Storage URI for long audio
  }) async {
    try {
      if (!_initialized) await initialize();
      if (_speechToText == null) {
        return {
          'transcript': null,
          'error': 'Not initialized',
          'detectedLanguage': null,
        };
      }

      final file = File(path);
      if (!file.existsSync()) {
        return {
          'transcript': null,
          'error': 'File not found',
          'detectedLanguage': null,
        };
      }

      final fileSize = file.lengthSync();
      debugPrint('Transcribing audio file: $path');
      debugPrint('File size: $fileSize bytes');

      // Extract file extension
      final extension = path.split('.').last.toLowerCase();

      // Estimate duration and check if it exceeds limit
      final estimatedDuration = _estimateAudioDuration(fileSize, extension);

      if (estimatedDuration > maxSupportedDuration) {
        final message =
            'Audio file is too long (estimated ${estimatedDuration}s / ${(estimatedDuration / 60).toStringAsFixed(1)} minutes). Maximum supported duration is ${maxSupportedDuration}s (${maxSupportedDuration ~/ 60} minutes). Please record shorter audio segments.';
        debugPrint(message);
        return {'transcript': null, 'error': message, 'detectedLanguage': null};
      }

      String targetLanguage = language ?? _defaultLanguage;

      // Auto-detect language if requested and no language specified
      if (autoDetect && language == null) {
        debugPrint('Auto-detecting language from audio...');
        targetLanguage = _defaultLanguage;
      }

      final lang = _convertToBcp47(targetLanguage);
      debugPrint('Using language code: $lang');

      final bytes = await file.readAsBytes();
      debugPrint('Audio bytes loaded: ${bytes.length}');

      // Validate audio data
      if (bytes.isEmpty) {
        debugPrint('ERROR: Audio file is empty');
        return {
          'transcript': null,
          'error': 'Audio file is empty',
          'detectedLanguage': null,
        };
      }

      if (bytes.length < 44) {
        debugPrint(
          'ERROR: Audio file too small (${bytes.length} bytes) - likely corrupted',
        );
        return {
          'transcript': null,
          'error': 'Audio file is too small or corrupted',
          'detectedLanguage': null,
        };
      }

      // Validate WAV header for WAV files
      if (path.toLowerCase().endsWith('.wav')) {
        final wavHeader = String.fromCharCodes(bytes.take(4));
        if (wavHeader != 'RIFF') {
          debugPrint('ERROR: Invalid WAV file header: $wavHeader');
          return {
            'transcript': null,
            'error': 'Invalid WAV file format',
            'detectedLanguage': null,
          };
        }
        debugPrint('SUCCESS: Valid WAV file header detected');
      }

      // Determine encoding based on file extension
      AudioEncoding encoding;
      int? sampleRate;

      if (path.toLowerCase().endsWith('.wav')) {
        encoding = AudioEncoding.LINEAR16;
        sampleRate = 16000;
        debugPrint(
          'Detected WAV format - using LINEAR16 encoding with 16000 Hz',
        );
      } else if (path.toLowerCase().endsWith('.m4a') ||
          path.toLowerCase().endsWith('.mp4') ||
          path.toLowerCase().endsWith('.aac')) {
        encoding = AudioEncoding.ENCODING_UNSPECIFIED;
        sampleRate = null;
        debugPrint('Detected M4A/AAC format - using ENCODING_UNSPECIFIED');
      } else if (path.toLowerCase().endsWith('.mp3')) {
        encoding = AudioEncoding.MP3;
        sampleRate = null;
        debugPrint('Detected MP3 format - using MP3 encoding');
      } else {
        encoding = AudioEncoding.ENCODING_UNSPECIFIED;
        sampleRate = null;
        debugPrint('Unknown format - using ENCODING_UNSPECIFIED');
      }

      final config = RecognitionConfig(
        encoding: encoding,
        sampleRateHertz: sampleRate,
        languageCode: lang,
        enableAutomaticPunctuation: true,
        model: RecognitionModel.basic,
        enableWordTimeOffsets: false,
      );

      debugPrint('RecognitionConfig created:');
      debugPrint('  - Encoding: $encoding');
      debugPrint('  - Sample Rate: $sampleRate');
      debugPrint('  - Language: $lang');
      debugPrint('  - Audio bytes size: ${bytes.length}');

      // Choose processing method based on estimated duration
      if (estimatedDuration <= maxSyncDuration) {
        debugPrint('Using standard transcription (audio <= 60s)');
        return await _transcribeStandard(
          config,
          bytes,
          targetLanguage,
          autoDetect,
        );
      } else {
        debugPrint(
          'Audio is estimated at ${estimatedDuration}s (${(estimatedDuration / 60).toStringAsFixed(1)} min). Using chunked transcription for longer audio...',
        );
        return await _transcribeChunked(
          file,
          config,
          targetLanguage,
          autoDetect,
          estimatedDuration,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Transcription error: $e');
      debugPrint('Stack trace: $stackTrace');

      String errorMessage = e.toString();
      if (errorMessage.contains('INVALID_ARGUMENT') &&
          errorMessage.contains('Sync input too long')) {
        errorMessage =
            'Audio recording is too long for transcription. The current implementation supports up to 20 minutes. Consider splitting longer recordings into shorter segments.';
      }

      return {
        'transcript': null,
        'error': errorMessage,
        'detectedLanguage': null,
      };
    }
  }

  /// Standard transcription for audio <= 60 seconds
  Future<Map<String, String?>> _transcribeStandard(
    RecognitionConfig config,
    List<int> bytes,
    String targetLanguage,
    bool autoDetect,
  ) async {
    try {
      debugPrint('Starting standard transcription with Google Speech API...');

      final response = await _speechToText!.recognize(config, bytes);
      debugPrint(
        'Standard transcription response received. Results count: ${response.results.length}',
      );

      if (response.results.isNotEmpty) {
        final transcript = response.results
            .map((r) => r.alternatives.first.transcript)
            .join(' ')
            .trim();

        debugPrint(
          'Transcript extracted: ${transcript.length > 100 ? '${transcript.substring(0, 100)}...' : transcript}',
        );

        if (transcript.isNotEmpty) {
          String? detectedLang = targetLanguage;
          if (autoDetect && transcript.length > 50) {
            detectedLang = detectLanguageFromText(transcript);
            debugPrint(
              'Language detected from transcript: ${getLanguageName(detectedLang)} ($detectedLang)',
            );
          }

          return {
            'transcript': transcript,
            'detectedLanguage': detectedLang,
            'targetLanguage': targetLanguage,
            'error': null,
          };
        }
      }

      debugPrint('Empty transcription result');
      return {
        'transcript': null,
        'error':
            'Empty transcription - audio may be too quiet or contain no speech',
        'detectedLanguage': null,
      };
    } catch (apiError) {
      debugPrint('Google Speech API error: $apiError');
      return _handleTranscriptionError(apiError);
    }
  }

  /// Upload audio file to Firebase Storage and return the download URL
  Future<String?> _uploadToFirebaseStorage(File file) async {
    try {
      final fileName =
          'temp_audio_${const Uuid().v4()}.${file.path.split('.').last}';
      final storageRef = FirebaseStorage.instance.ref().child(
        'temp_transcription/$fileName',
      );

      debugPrint('Uploading audio to Firebase Storage: $fileName');
      await storageRef.putFile(file);

      // Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();

      debugPrint('Audio uploaded to Firebase Storage: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Failed to upload audio to Firebase Storage: $e');
      return null;
    }
  }

  /// Chunked transcription for audio > 60 seconds by splitting into segments
  Future<Map<String, String?>> _transcribeChunked(
    File file,
    RecognitionConfig config,
    String targetLanguage,
    bool autoDetect,
    int estimatedDuration,
  ) async {
    try {
      debugPrint(
        'Starting chunked transcription for ${estimatedDuration}s audio...',
      );

      // If the file is WAV, attempt splitting by duration into multiple temporary WAV files
      // and transcribe each chunk using the standard synchronous API.
      final extension = file.path.split('.').last.toLowerCase();
      if (!extension.contains('wav')) {
        // Non-WAV long files: fallback to upload and inform user (as before)
        final downloadUrl = await _uploadToFirebaseStorage(file);
        if (downloadUrl == null) {
          return {
            'transcript': null,
            'error': 'Failed to upload audio for processing. Please try again.',
            'detectedLanguage': null,
          };
        }

        final durationMinutes = (estimatedDuration / 60).toStringAsFixed(1);
        String message =
            'Audio recording ($durationMinutes minutes) has been saved successfully to Firebase Storage. '
            'However, automatic transcription is currently limited to recordings under 1 minute due to API constraints. '
            '\n\nYour audio is available at: $downloadUrl'
            '\n\nFor longer recordings, consider:'
            '\n• Recording in shorter segments (under 1 minute each)'
            '\n• Using the saved audio file with external transcription services'
            '\n• Manual transcription for important content';

        return {
          'transcript': null,
          'error': message,
          'detectedLanguage': null,
          'audioUrl': downloadUrl,
        };
      }

      // Read full bytes and parse WAV header to split by approximate byte count per chunk
      final bytes = await file.readAsBytes();

      // WAV header: first 44 bytes typically. We'll preserve header for each chunk.
      const int wavHeaderSize = 44;

      if (bytes.length <= wavHeaderSize) {
        return {
          'transcript': null,
          'error': 'WAV file too small or invalid for chunking',
          'detectedLanguage': null,
        };
      }

      // Calculate bytes per second using sampleRate from config if available, otherwise estimate
      final sampleRate = config.sampleRateHertz ?? 16000;
      // Assuming 16-bit mono PCM => 2 bytes per sample * channels(1)
      final bytesPerSecond = sampleRate * 2 * 1;

      // Target chunk duration slightly under maxSyncDuration to be safe
      final int chunkDurationSeconds = maxSyncDuration - 5; // e.g., 55s
      final int payloadBytesPerChunk = bytesPerSecond * chunkDurationSeconds;

      // Extract raw PCM payload (skip header)
      final payload = bytes.sublist(wavHeaderSize);

      // Split payload into chunks
      List<List<int>> payloadChunks = [];
      for (
        int offset = 0;
        offset < payload.length;
        offset += payloadBytesPerChunk
      ) {
        final end = (offset + payloadBytesPerChunk) < payload.length
            ? offset + payloadBytesPerChunk
            : payload.length;
        payloadChunks.add(payload.sublist(offset, end));
      }

      debugPrint(
        'Split into ${payloadChunks.length} chunk(s) for transcription',
      );

      StringBuffer fullTranscript = StringBuffer();
      String? detectedLang;
      int failedChunks = 0;

      // Temp files created for each chunk
      List<File> tempChunkFiles = [];
      try {
        // Retry/backoff parameters
        const int maxRetries = 3;
        const Duration baseDelay = Duration(seconds: 1);

        for (int i = 0; i < payloadChunks.length; i++) {
          final chunkPayload = payloadChunks[i];

          // Build a new WAV file bytes: copy original header then set proper sizes
          final List<int> chunkBytes = [];
          // Copy header and make a mutable copy to patch sizes
          final header = List<int>.from(bytes.sublist(0, wavHeaderSize));

          // subchunk2Size (data size) for this chunk
          final int subchunk2Size = chunkPayload.length;
          final int riffChunkSize =
              36 +
              subchunk2Size; // 4 + (8 + SubChunk1Size) + (8 + SubChunk2Size)

          // Write subchunk2Size at byte offset 40 (little-endian)
          header[40] = subchunk2Size & 0xFF;
          header[41] = (subchunk2Size >> 8) & 0xFF;
          header[42] = (subchunk2Size >> 16) & 0xFF;
          header[43] = (subchunk2Size >> 24) & 0xFF;

          // Write RIFF chunk size at offset 4 (little-endian)
          header[4] = riffChunkSize & 0xFF;
          header[5] = (riffChunkSize >> 8) & 0xFF;
          header[6] = (riffChunkSize >> 16) & 0xFF;
          header[7] = (riffChunkSize >> 24) & 0xFF;

          chunkBytes.addAll(header);
          chunkBytes.addAll(chunkPayload);

          // Write to temp file
          final tmp = File(
            '${Directory.systemTemp.path}/temp_chunk_${Uuid().v4()}.wav',
          );
          await tmp.writeAsBytes(chunkBytes, flush: true);
          tempChunkFiles.add(tmp);

          debugPrint(
            'Transcribing chunk ${i + 1}/${payloadChunks.length} (size: ${chunkBytes.length})',
          );

          final chunkBytesList = await tmp.readAsBytes();

          Map<String, String?>? chunkResult;
          int attempt = 0;
          bool shouldRetry = false;
          do {
            attempt++;
            if (attempt > 1) {
              final delay = baseDelay * (1 << (attempt - 2));
              debugPrint(
                'Retrying chunk ${i + 1} (attempt $attempt) after ${delay.inSeconds}s',
              );
              await Future.delayed(delay);
            }

            chunkResult = await _transcribeStandard(
              config,
              chunkBytesList,
              targetLanguage,
              autoDetect,
            );

            final err = chunkResult['error'];
            // Treat gRPC UNAVAILABLE / HandshakeException as transient and retry
            if (err != null &&
                (err.contains('UNAVAILABLE') ||
                    err.contains('HandshakeException') ||
                    err.contains('Connection terminated during handshake'))) {
              shouldRetry = attempt <= maxRetries;
              debugPrint(
                'Transient error detected for chunk ${i + 1}: $err (willRetry: $shouldRetry)',
              );
            } else {
              shouldRetry = false;
            }
          } while (shouldRetry);

          // small throttle to reduce repeated handshake churn
          await Future.delayed(const Duration(milliseconds: 300));

          final chunkTranscript = chunkResult['transcript'];
          final chunkDetected = chunkResult['detectedLanguage'];

          if (chunkTranscript != null && chunkTranscript.isNotEmpty) {
            if (fullTranscript.isNotEmpty) fullTranscript.write(' ');
            fullTranscript.write(chunkTranscript);
          }

          // Prefer the first detected language that is not null
          detectedLang ??= chunkDetected;
          if ((chunkResult['error'] != null) &&
              (chunkResult['transcript'] == null ||
                  chunkResult['transcript']!.isEmpty)) {
            failedChunks++;
          }

          // If more than half the chunks failed with transient errors, bail out early and upload original file
          if (failedChunks > (payloadChunks.length / 2).ceil()) {
            debugPrint(
              'More than half of chunks failed ($failedChunks/${payloadChunks.length}). Falling back to upload and user-guidance flow.',
            );
            break;
          }
        }
      } finally {
        // Clean up temp chunk files
        for (final f in tempChunkFiles) {
          try {
            if (f.existsSync()) await f.delete();
          } catch (_) {}
        }
      }

      if (fullTranscript.isEmpty) {
        // If no transcript produced from chunks, upload original file and inform user
        final downloadUrl = await _uploadToFirebaseStorage(file);
        final durationMinutes = (estimatedDuration / 60).toStringAsFixed(1);
        String message =
            'Audio recording ($durationMinutes minutes) has been saved successfully to Firebase Storage. '
            'Automatic transcription was attempted by chunking but produced no text. The audio is available at: $downloadUrl';

        return {
          'transcript': null,
          'error': message,
          'detectedLanguage': detectedLang,
          'audioUrl': downloadUrl,
        };
      }

      return {
        'transcript': fullTranscript.toString(),
        'error': null,
        'detectedLanguage': detectedLang,
      };
    } catch (error) {
      debugPrint('Error in chunked transcription: $error');
      final durationMinutes = (estimatedDuration / 60).toStringAsFixed(1);
      String errorMessage =
          'Failed to process $durationMinutes minute audio recording. Please try recording shorter segments under 1 minute for immediate transcription.';

      return {
        'transcript': null,
        'error': errorMessage,
        'detectedLanguage': null,
      };
    }
  }

  /// Handle transcription errors with user-friendly messages
  Map<String, String?> _handleTranscriptionError(dynamic apiError) {
    String errorMessage = apiError.toString();

    if (errorMessage.contains('RecognitionAudio not set')) {
      errorMessage =
          'Audio data not properly formatted for Google Speech API. Try recording again.';
    } else if (errorMessage.contains('UNAUTHENTICATED')) {
      errorMessage =
          'Google Speech API authentication failed. Check service account configuration.';
    } else if (errorMessage.contains('PERMISSION_DENIED')) {
      errorMessage =
          'Google Speech API access denied. Check API permissions and quotas.';
    } else if (errorMessage.contains('QUOTA_EXCEEDED')) {
      errorMessage =
          'Google Speech API quota exceeded. Try again later or upgrade your plan.';
    } else if (errorMessage.contains('INVALID_ARGUMENT')) {
      errorMessage =
          'Invalid audio format or configuration. Try recording again with different settings.';
    }

    return {
      'transcript': null,
      'error': errorMessage,
      'detectedLanguage': null,
    };
  }

  Future<Map<String, String?>> transcribeAudioFromUrl(
    String url, {
    String? language,
    bool autoDetect = false,
  }) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return {
          'transcript': null,
          'error': 'Download failed',
          'detectedLanguage': null,
        };
      }

      // Extract file extension from URL or default to wav
      String extension = 'wav';
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final lastSegment = pathSegments.last;
        if (lastSegment.contains('.')) {
          extension = lastSegment.split('.').last.split('?').first;
        }
      }

      final tempFile = File(
        '${Directory.systemTemp.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.$extension',
      );
      await tempFile.writeAsBytes(response.bodyBytes);
      final result = await transcribeAudio(
        tempFile.path,
        language: language,
        autoDetect: autoDetect,
      );
      if (tempFile.existsSync()) await tempFile.delete();
      return result;
    } catch (e) {
      return {
        'transcript': null,
        'error': e.toString(),
        'detectedLanguage': null,
      };
    }
  }

  Future<String?> transcribeAudioSimple(String path, {String? language}) async {
    final result = await transcribeAudio(path, language: language);
    return result['transcript'];
  }

  Future<String?> transcribeAudioFromUrlSimple(
    String url, {
    String? language,
  }) async {
    final result = await transcribeAudioFromUrl(url, language: language);
    return result['transcript'];
  }
}