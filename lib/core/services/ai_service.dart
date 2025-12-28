import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class AiService {
  final String _gcloudApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
  final String _gptModel = dotenv.env['GOOGLE_GEMINI_MODEL'] ?? 'gemini-pro';

  AiService() {
    if (_gcloudApiKey.isEmpty) {
      debugPrint(
        'Warning: GOOGLE_API_KEY not set in .env. AI calls will fail without a valid key.',
      );
    }
    Gemini.init(apiKey: _gcloudApiKey);
    debugPrint('AiService initialized with Gemini model: $_gptModel');
  }

  Future<Map<String, dynamic>> processTranscript(
    String transcript,
    String meetingTitle, {
    String? detectedLanguage,
  }) async {
    // Force English output regardless of detected language
    // We intentionally avoid passing language context to prevent non-English responses
    String languageContext = '';

    final prompt =
        '''
Analyze the following meeting transcript and extract structured information in JSON format. All output MUST be in English only. If the transcript is not in English, translate and summarize it into natural English while preserving names, figures, and intent.

Meeting Title: "$meetingTitle"$languageContext
Transcript: "$transcript"

Return ONLY a JSON object with this exact structure:
{
  "title": "Brief descriptive meeting title (improve generic titles based on content)",
  "description": "2-3 sentence English summary of what this meeting was about",
  "summary": "Detailed English summary covering key discussion points, decisions made, and important topics discussed",
  "toDo": [
    {
      "todoId": "unique_identifier",
      "title": "Clear, actionable task description (English)",
      "isCompleted": false,
      "priority": "One of: low | medium | high | urgent"
    }
  ]
}

Strict rules:
- Respond in English only, regardless of transcript language.
- Return ONLY the JSON object, no markdown, no backticks, no commentary.
- If no tasks are mentioned, return an empty array for toDo.
''';

    try {
      if (_gcloudApiKey.isEmpty) {
        throw Exception('Google API key not configured');
      }

      final gemini = Gemini.instance;
      final response = await gemini.prompt(
        parts: [Part.text(prompt)],
        model: _gptModel,
        generationConfig: GenerationConfig(
          temperature: 0.3,
          maxOutputTokens: 2048,
          topP: 0.8,
          topK: 40,
        ),
      );

      final content = response?.output ?? '';
      if (content.isEmpty) {
        throw Exception('No content in Gemini API response');
      }

      debugPrint(
        'AI content extracted: ${content.length > 1000 ? content.substring(0, 1000) : content}',
      );

      String cleanJson;
      try {
        cleanJson = _extractJsonFromResponse(content);
      } catch (e) {
        debugPrint('Failed to extract JSON from content: $e');
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          cleanJson = jsonMatch.group(0)!;
        } else {
          throw Exception('AI response missing JSON content');
        }
      }

      final Map<String, dynamic> parsedData =
          jsonDecode(cleanJson) as Map<String, dynamic>;
      _validateResponse(parsedData);
      return parsedData;
    } catch (e, st) {
      debugPrint('processTranscript failed: $e\n$st');
      try {
        return _createFallbackResponse(meetingTitle, transcript);
      } catch (fallbackError) {
        debugPrint('Fallback response also failed: $fallbackError');
        rethrow;
      }
    }
  }

  String _extractJsonFromResponse(String response) {
    // Remove any markdown formatting
    String cleaned = response.trim();

    // Remove markdown code blocks if present
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    }
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    // Find JSON boundaries
    final jsonStart = cleaned.indexOf('{');
    final jsonEnd = cleaned.lastIndexOf('}') + 1;

    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      return cleaned.substring(jsonStart, jsonEnd);
    }

    throw Exception('No valid JSON found in AI response');
  }

  void _validateResponse(Map<String, dynamic> data) {
    // Check required fields
    if (!data.containsKey('title') ||
        !data.containsKey('description') ||
        !data.containsKey('summary') ||
        !data.containsKey('toDo')) {
      throw Exception('AI response missing required fields');
    }

    // Validate toDo structure
    if (data['toDo'] is! List) {
      throw Exception('toDo must be a list');
    }

    for (var todo in data['toDo']) {
      if (todo is! Map<String, dynamic> ||
          !todo.containsKey('todoId') ||
          !todo.containsKey('title') ||
          !todo.containsKey('isCompleted') ||
          !todo.containsKey('priority')) {
        throw Exception('Invalid todo structure in AI response');
      }
    }
  }

  Map<String, dynamic> _createFallbackResponse(
    String meetingTitle,
    String transcript,
  ) {
    return {
      'title': meetingTitle.isNotEmpty ? meetingTitle : 'Meeting Recording',
      'description':
          'Meeting transcript was processed but detailed analysis failed.',
      'summary': transcript.length > 500
          ? '${transcript.substring(0, 500)}...'
          : transcript,
      'toDo': <Map<String, dynamic>>[], // Empty todo list
    };
  }

  /// Process YouTube video using Gemini's video understanding capabilities
  /// or fallback to metadata-based analysis
  Future<Map<String, dynamic>> processYoutubeVideo({
    required String videoUrl,
    required String videoTitle,
    required String channelName,
    required String videoDescription,
    String? transcript,
  }) async {
    try {
      if (_gcloudApiKey.isEmpty) {
        throw Exception('Google API key not configured');
      }

      final gemini = Gemini.instance;

      // If transcript is available, use the standard processTranscript method
      if (transcript != null && transcript.isNotEmpty) {
        debugPrint('Processing YouTube video with available transcript');
        return await processTranscript(transcript, videoTitle);
      }

      // Otherwise, use video metadata for analysis
      debugPrint(
        'Processing YouTube video using metadata (no transcript available)',
      );

      final metadataContext =
          '''
Video Title: $videoTitle
Channel: $channelName
Video Description: $videoDescription
''';

      final prompt =
          '''
Analyze this YouTube video based on its metadata and generate a comprehensive summary.

$metadataContext

Based on this information, create a detailed analysis in JSON format. All output MUST be in English.

Return ONLY a JSON object with this exact structure:
{
  "title": "Improved descriptive title based on content",
  "description": "2-3 sentence English summary of what this video is about",
  "summary": "Detailed English summary covering the main topics, key points, and important information from the video description and title. Be comprehensive and informative.",
  "toDo": [
    {
      "todoId": "unique_identifier",
      "title": "Actionable task or key takeaway (English)",
      "isCompleted": false,
      "priority": "One of: low | medium | high | urgent"
    }
  ]
}

Strict rules:
- Respond in English only
- Return ONLY the JSON object, no markdown, no backticks
- Extract actionable insights or key takeaways for the toDo list
- If no clear actions can be derived, return an empty toDo array
- Make the summary detailed and informative based on the description
''';

      final response = await gemini.prompt(
        parts: [Part.text(prompt)],
        model: _gptModel,
        generationConfig: GenerationConfig(
          temperature: 0.3,
          maxOutputTokens: 2048,
          topP: 0.8,
          topK: 40,
        ),
      );

      final content = response?.output ?? '';
      if (content.isEmpty) {
        throw Exception('No content in Gemini API response');
      }

      debugPrint(
        'AI video analysis extracted: ${content.length > 500 ? content.substring(0, 500) : content}...',
      );

      String cleanJson;
      try {
        cleanJson = _extractJsonFromResponse(content);
      } catch (e) {
        debugPrint('Failed to extract JSON from content: $e');
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          cleanJson = jsonMatch.group(0)!;
        } else {
          throw Exception('AI response missing JSON content');
        }
      }

      final Map<String, dynamic> parsedData =
          jsonDecode(cleanJson) as Map<String, dynamic>;
      _validateResponse(parsedData);
      return parsedData;
    } catch (e, st) {
      debugPrint('processYoutubeVideo failed: $e\n$st');

      // Create enhanced fallback response using available metadata
      return {
        'title': videoTitle,
        'description':
            'Video from $channelName. ${videoDescription.length > 200 ? videoDescription.substring(0, 200) + "..." : videoDescription}',
        'summary':
            'Title: $videoTitle\n\nChannel: $channelName\n\nDescription: $videoDescription\n\nNote: AI analysis was unavailable. This summary is based on video metadata.',
        'toDo': <Map<String, dynamic>>[],
      };
    }
  }
}