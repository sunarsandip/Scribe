import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:scribe/core/services/ai_service.dart';
import 'package:scribe/core/services/youtube_service.dart';
import 'package:scribe/models/youtube_summary_model.dart';

class YoutubeSummaryController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid.toString();
  final YoutubeService youtubeService = YoutubeService();
  final AiService aiService = AiService();

  Future<bool> saveYoutubeSummary(YoutubeSummaryModel newYoutubeSummary) async {
    try {
      final docRef = firestore.collection("youtubeSummary").doc();
      final summaryId = docRef.id;
      await docRef.set(
        newYoutubeSummary.copyWith(summaryId: summaryId).toMap(),
      );
      debugPrint("Youtube Summary Saved");
      return true;
    } catch (e) {
      debugPrint("failed to save youtube summary: $e");
      return false;
    }
  }

  /// Get all YouTube summaries for a specific user
  Stream<List<YoutubeSummaryModel>> getUserYoutubeSummaries(String uid) {
    try {
      return firestore
          .collection("youtubeSummary")
          .where("ownerId", isEqualTo: uid)
          .snapshots()
          .map((querySnapshot) {
            return querySnapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data();
              data['summaryId'] = doc.id;
              return YoutubeSummaryModel.fromMap(data);
            }).toList();
          });
    } catch (e) {
      debugPrint("Failed to get YouTube summaries: $e");
      return Stream.value([]);
    }
  }

  /// Get a single YouTube summary by ID
  Future<YoutubeSummaryModel?> getYoutubeSummaryById(String summaryId) async {
    try {
      final doc = await firestore
          .collection("youtubeSummary")
          .doc(summaryId)
          .get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['summaryId'] = doc.id;
      return YoutubeSummaryModel.fromMap(data);
    } catch (e) {
      debugPrint("Failed to fetch YouTube summary by id: $e");
      return null;
    }
  }

  /// Delete a YouTube summary
  Future<Map<String, dynamic>> deleteYoutubeSummary(String summaryId) async {
    try {
      await firestore.collection("youtubeSummary").doc(summaryId).delete();
      return {
        "success": true,
        "message": "YouTube summary deleted successfully!",
      };
    } catch (e) {
      debugPrint("Failed to delete YouTube summary: $e");
      return {
        "success": false,
        "message": "Failed to delete YouTube summary: $e",
      };
    }
  }

  /// Update a YouTube summary
  Future<Map<String, dynamic>> updateYoutubeSummary(
    String summaryId,
    YoutubeSummaryModel updatedSummary,
  ) async {
    try {
      await firestore
          .collection("youtubeSummary")
          .doc(summaryId)
          .update(updatedSummary.toMap());
      return {
        "success": true,
        "message": "YouTube summary updated successfully!",
      };
    } catch (e) {
      debugPrint("Failed to update YouTube summary: $e");
      return {"success": false, "message": "Failed to update YouTube summary!"};
    }
  }

  /// Generate YouTube video summary from URL with multi-tier fallback
  /// Tier 1: Try YouTube Captions API
  /// Tier 2: Use Gemini AI with video metadata (no transcript)
  /// Tier 3: Create basic summary from metadata only
  Future<Map<String, dynamic>> generateYoutubeSummary(String videoUrl) async {
    try {
      debugPrint('Starting YouTube summary generation for URL: $videoUrl');

      // Step 1: Validate URL
      if (!youtubeService.isValidYoutubeUrl(videoUrl)) {
        return {
          'success': false,
          'message': 'Invalid YouTube URL. Please check and try again.',
          'summary': null,
        };
      }

      // Step 2: Extract video ID
      final videoId = youtubeService.extractVideoId(videoUrl);
      if (videoId == null || videoId.isEmpty) {
        return {
          'success': false,
          'message': 'Could not extract video ID from URL.',
          'summary': null,
        };
      }

      debugPrint('Extracted video ID: $videoId');

      // Step 3: Fetch video metadata (title, channel, duration, description, upload date)
      debugPrint('Fetching video metadata...');
      final metadataResult = await youtubeService.fetchVideoMetadata(videoId);

      if (metadataResult['error'] != null) {
        return {
          'success': false,
          'message':
              'Failed to fetch video metadata: ${metadataResult['error']}',
          'summary': null,
        };
      }

      final videoTitle = metadataResult['videoTitle'] ?? 'Unknown';
      final channelName = metadataResult['channelName'] ?? 'Unknown';
      final videoUploadedDate = metadataResult['videoUploadedDate'] ?? '';
      final videoDescription = metadataResult['videoDescription'] ?? '';

      debugPrint('Video metadata retrieved: $videoTitle by $channelName');

      // Step 4: Try to fetch video transcript (Tier 1)
      debugPrint(
        'Attempting to fetch video transcript from YouTube Captions API...',
      );
      final transcriptResult = await youtubeService.fetchVideoTranscript(
        videoId,
      );

      final List<String> transcript = List<String>.from(
        transcriptResult['transcript'] ?? [],
      );

      String aiSummary;
      String aiDescription;
      List<String> finalTranscript;
      String processingMethod;

      if (transcript.isNotEmpty) {
        // Success: We have a transcript from YouTube Captions API
        debugPrint('✓ Transcript fetched: ${transcript.length} segments');
        debugPrint('Processing with Gemini AI using full transcript...');

        final transcriptText = transcript.join(' ');
        final aiResult = await aiService.processTranscript(
          transcriptText,
          videoTitle,
        );

        aiSummary = aiResult['summary'] ?? 'Summary generation failed';
        aiDescription = aiResult['description'] ?? '';
        finalTranscript = transcript;
        processingMethod = 'YouTube Captions + Gemini AI';

        debugPrint('✓ AI summary generated successfully using transcript');
      } else {
        // Tier 2: No transcript available, use Gemini with metadata
        debugPrint('⚠ No transcript available from YouTube Captions API');
        debugPrint('⚠ Transcript error: ${transcriptResult['error']}');
        debugPrint('Falling back to Gemini AI analysis with video metadata...');

        final aiResult = await aiService.processYoutubeVideo(
          videoUrl: videoUrl,
          videoTitle: videoTitle,
          channelName: channelName,
          videoDescription: videoDescription,
        );

        aiSummary = aiResult['summary'] ?? 'Summary generation failed';
        aiDescription = aiResult['description'] ?? '';

        // Create a synthetic transcript from the description for storage
        finalTranscript = [
          'Video Title: $videoTitle',
          'Channel: $channelName',
          'Description: $videoDescription',
          '',
          'Note: Full transcript was not available. Summary generated from video metadata using AI.',
        ];
        processingMethod = 'Gemini AI (Metadata-based)';

        debugPrint('✓ AI summary generated using metadata fallback');
      }

      // Step 5: Create YouTube Summary Model with all data
      final now = DateTime.now();
      final createdAtString = now.toIso8601String();

      final youtubeSummaryModel = YoutubeSummaryModel(
        summaryId: '', // Will be set when saving
        videoTitle: videoTitle,
        ownerId: uid,
        videoDescription: videoDescription,
        aiDescription: aiDescription,
        createdAt: createdAtString,
        summary: aiSummary,
        transcript: finalTranscript,
        channelName: channelName,
        videoUploadedDate: videoUploadedDate,
      );

      // Step 6: Save to Firestore
      debugPrint('Saving summary to Firestore...');
      final saveSuccess = await saveYoutubeSummary(youtubeSummaryModel);

      if (!saveSuccess) {
        return {
          'success': false,
          'message': 'Failed to save summary to database.',
          'summary': null,
        };
      }

      debugPrint('YouTube summary generation completed successfully');
      debugPrint('Processing method used: $processingMethod');

      return {
        'success': true,
        'message':
            'YouTube summary generated successfully! (Method: $processingMethod)',
        'summary': youtubeSummaryModel,
      };
    } catch (e, stackTrace) {
      debugPrint('Error generating YouTube summary: $e');
      debugPrint('Stack trace: $stackTrace');

      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
        'summary': null,
      };
    }
  }
}