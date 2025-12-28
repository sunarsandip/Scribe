import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class YoutubeService {
  static final YoutubeService _instance = YoutubeService._internal();

  YoutubeService._internal();

  factory YoutubeService() {
    return _instance;
  }

  late String _apiKey;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    _apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';

    if (_apiKey.isEmpty) {
      debugPrint('ERROR: GOOGLE_API_KEY not found in .env file');
      throw Exception('GOOGLE_API_KEY is not configured');
    }
    _initialized = true;
    debugPrint('YoutubeService initialized with API key');
  }

  /// Extract video ID from YouTube URL
  String? extractVideoId(String url) {
    try {
      Uri uri = Uri.parse(url);

      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      }

      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      }

      if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'embed') {
        return uri.pathSegments[1];
      }

      debugPrint('Unable to extract video ID from URL: $url');
      return null;
    } catch (e) {
      debugPrint('Error extracting video ID: $e');
      return null;
    }
  }

  /// Fetch video metadata from YouTube API v3
  Future<Map<String, String?>> fetchVideoMetadata(String videoId) async {
    try {
      if (!_initialized) await initialize();

      final String url =
          'https://www.googleapis.com/youtube/v3/videos?id=$videoId&key=$_apiKey&part=snippet,contentDetails,statistics';

      debugPrint('Fetching video metadata for video ID: $videoId');

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('YouTube API request timeout'),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['items'] == null || (json['items'] as List).isEmpty) {
          return {
            'error': 'Video not found',
            'videoTitle': null,
            'channelName': null,
            'videoUploadedDate': null,
            'duration': null,
            'videoDescription': null,
          };
        }

        final item = json['items'][0] as Map<String, dynamic>;
        final snippet = item['snippet'] as Map<String, dynamic>;
        final contentDetails = item['contentDetails'] as Map<String, dynamic>;

        final String videoTitle = snippet['title'] ?? '';
        final String channelName = snippet['channelTitle'] ?? '';
        final String videoUploadedDate = snippet['publishedAt'] ?? '';
        final String duration = _parseDuration(
          contentDetails['duration'] ?? '',
        );
        final String videoDescription = snippet['description'] ?? '';

        debugPrint('Video metadata fetched:');
        debugPrint('  - Title: $videoTitle');
        debugPrint('  - Channel: $channelName');
        debugPrint('  - Duration: $duration');
        debugPrint('  - Upload Date: $videoUploadedDate');

        return {
          'videoTitle': videoTitle,
          'channelName': channelName,
          'videoUploadedDate': videoUploadedDate,
          'duration': duration,
          'videoDescription': videoDescription,
          'error': null,
        };
      } else if (response.statusCode == 403) {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        final errorDetails = errorBody['error'] as Map<String, dynamic>?;
        final errorMessage = errorDetails?['message'] ?? 'API access forbidden';

        debugPrint('YouTube API 403 Error: $errorMessage');

        if (errorMessage.contains('quota') || errorMessage.contains('QUOTA')) {
          return {
            'error':
                'YouTube API quota exceeded. Please try again later or upgrade your API quota in Google Cloud Console.',
            'videoTitle': null,
            'channelName': null,
            'videoUploadedDate': null,
            'duration': null,
            'videoDescription': null,
          };
        } else if (errorMessage.contains('service') ||
            errorMessage.contains('blocked')) {
          return {
            'error':
                'YouTube API is blocked or not enabled. Please check your Google Cloud Console settings.',
            'videoTitle': null,
            'channelName': null,
            'videoUploadedDate': null,
            'duration': null,
            'videoDescription': null,
          };
        }

        return {
          'error': errorMessage,
          'videoTitle': null,
          'channelName': null,
          'videoUploadedDate': null,
          'duration': null,
          'videoDescription': null,
        };
      } else {
        final errorMsg =
            'YouTube API error: ${response.statusCode} - ${response.body}';
        debugPrint(errorMsg);

        return {
          'error': errorMsg,
          'videoTitle': null,
          'channelName': null,
          'videoUploadedDate': null,
          'duration': null,
          'videoDescription': null,
        };
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching video metadata: $e');
      debugPrint('Stack trace: $stackTrace');

      return {
        'error': e.toString(),
        'videoTitle': null,
        'channelName': null,
        'videoUploadedDate': null,
        'duration': null,
        'videoDescription': null,
      };
    }
  }

  /// Returns list of caption lines with timestamps
  Future<Map<String, dynamic>> fetchVideoTranscript(String videoId) async {
    try {
      if (!_initialized) await initialize();

      debugPrint('Fetching captions for video ID: $videoId');

      // First, get caption track IDs
      final String captionUrl =
          'https://www.googleapis.com/youtube/v3/captions?videoId=$videoId&key=$_apiKey';

      final captionResponse = await http
          .get(Uri.parse(captionUrl))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('YouTube captions API timeout'),
          );

      if (captionResponse.statusCode != 200) {
        debugPrint(
          'Warning: Could not fetch captions list. Status: ${captionResponse.statusCode}',
        );
        return {
          'transcript': <String>[],
          'language': 'unknown',
          'error': 'Captions not available for this video',
        };
      }

      final json = jsonDecode(captionResponse.body) as Map<String, dynamic>;
      final items = json['items'] as List?;

      if (items == null || items.isEmpty) {
        debugPrint('No captions found for video');
        return {
          'transcript': <String>[],
          'language': 'unknown',
          'error': 'No captions available',
        };
      }

      // Prefer English captions, fallback to first available
      Map<String, dynamic>? selectedCaption;
      for (var item in items) {
        // Validate item structure before accessing nested properties
        if (item == null || item['snippet'] == null) continue;

        final language = item['snippet']['language'] ?? '';
        if (language.startsWith('en')) {
          selectedCaption = item;
          break;
        }
      }
      selectedCaption ??= items.first;

      // Validate selectedCaption structure
      if (selectedCaption == null || selectedCaption['snippet'] == null) {
        debugPrint('Invalid caption structure returned by API');
        return {
          'transcript': <String>[],
          'language': 'unknown',
          'error': 'Invalid caption data structure',
        };
      }

      final captionId = selectedCaption['id'];
      final language = selectedCaption['snippet']?['language'] ?? 'unknown';

      if (captionId == null) {
        debugPrint('Caption ID is null');
        return {
          'transcript': <String>[],
          'language': language,
          'error': 'Could not extract caption ID',
        };
      }

      debugPrint('Using caption track: $captionId (Language: $language)');

      // Fetch the actual transcript using the caption ID
      final String transcriptUrl =
          'https://www.googleapis.com/youtube/v3/captions/$captionId?key=$_apiKey';

      final transcriptResponse = await http
          .get(Uri.parse(transcriptUrl))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('YouTube transcript API timeout'),
          );

      if (transcriptResponse.statusCode == 200) {
        // Parse XML response
        final transcript = _parseTranscriptXml(transcriptResponse.body);

        debugPrint(
          'Transcript fetched successfully: ${transcript.length} segments',
        );

        return {'transcript': transcript, 'language': language, 'error': null};
      } else {
        debugPrint(
          'Failed to fetch transcript. Status: ${transcriptResponse.statusCode}',
        );
        return {
          'transcript': <String>[],
          'language': language,
          'error': 'Failed to download transcript',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching video transcript: $e');
      debugPrint('Stack trace: $stackTrace');

      return {
        'transcript': <String>[],
        'language': 'unknown',
        'error': e.toString(),
      };
    }
  }

  /// Parse XML transcript response from YouTube
  List<String> _parseTranscriptXml(String xmlContent) {
    try {
      final List<String> lines = [];

      // Simple XML parsing - extract text between <text> tags
      final regex = RegExp(r'<text[^>]*>([^<]+)<\/text>');
      final matches = regex.allMatches(xmlContent);

      for (var match in matches) {
        final text = match.group(1) ?? '';
        // Decode HTML entities
        String decodedText = text
            .replaceAll('&amp;', '&')
            .replaceAll('&quot;', '"')
            .replaceAll('&apos;', "'")
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .trim();

        if (decodedText.isNotEmpty) {
          lines.add(decodedText);
        }
      }

      return lines;
    } catch (e) {
      debugPrint('Error parsing transcript XML: $e');
      return [];
    }
  }

  /// Convert ISO 8601 duration to human-readable format
  String _parseDuration(String isoDuration) {
    try {
      // Remove PT prefix
      String duration = isoDuration.replaceFirst('PT', '');

      String result = '';

      if (duration.contains('H')) {
        final hours = int.parse(duration.split('H')[0]);
        result += '${hours}h ';
        duration = duration.split('H')[1];
      }

      if (duration.contains('M')) {
        final minutes = int.parse(duration.split('M')[0]);
        result += '${minutes}m ';
        duration = duration.split('M')[1];
      }

      if (duration.contains('S')) {
        final seconds = int.parse(duration.split('S')[0]);
        result += '${seconds}s';
      }

      return result.trim();
    } catch (e) {
      debugPrint('Error parsing duration: $e');
      return 'Unknown';
    }
  }

  /// Validate if the provided URL is a valid YouTube URL
  bool isValidYoutubeUrl(String url) {
    try {
      final Uri uri = Uri.parse(url);
      final isYoutubeHost =
          uri.host.contains('youtube.com') || uri.host.contains('youtu.be');

      return isYoutubeHost && extractVideoId(url) != null;
    } catch (e) {
      debugPrint('Invalid URL: $e');
      return false;
    }
  }
}