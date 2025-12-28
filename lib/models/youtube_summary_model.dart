// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:scribe/helpers/date_time_formatting_helper.dart';

class YoutubeSummaryModel {
  final String summaryId;
  final String videoTitle;
  final String ownerId;
  final String videoDescription;
  final String aiDescription;
  final String createdAt;
  final String summary;
  final List<String> transcript;
  final String channelName;
  final String videoUploadedDate;
  YoutubeSummaryModel({
    required this.summaryId,
    required this.videoTitle,
    required this.ownerId,
    required this.videoDescription,
    required this.aiDescription,
    required this.createdAt,
    required this.summary,
    required this.transcript,
    required this.channelName,
    required this.videoUploadedDate,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'summaryId':summaryId,
      'videoTitle': videoTitle,
      'ownerId': ownerId,
      'videoDescription': videoDescription,
      'aiDescription': aiDescription,
      'createdAt': createdAt,
      'summary': summary,
      'transcript': transcript,
      'channelName': channelName,
      'videoUploadedDate': videoUploadedDate,
    };
  }

  factory YoutubeSummaryModel.fromMap(Map<String, dynamic> map) {
    return YoutubeSummaryModel(
      summaryId: map['summaryId'] as String,
      videoTitle: map['videoTitle'] as String,
      ownerId: map['ownerId'] as String,
      videoDescription: map['videoDescription'] as String,
      aiDescription: map['aiDescription'] as String,
      createdAt: map['createdAt'] as String,
      summary: map['summary'] as String,
      transcript: List<String>.from((map['transcript'] as List<String>)),
      channelName: map['channelName'] as String,
      videoUploadedDate: map['videoUploadedDate'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory YoutubeSummaryModel.fromJson(String source) =>
      YoutubeSummaryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String get formattedDate => DateTimeFormattingHelper.formatDate(createdAt);
  String get formattedTime => DateTimeFormattingHelper.formatTime(createdAt);

  YoutubeSummaryModel copyWith({
    String? summaryId,
    String? videoTitle,
    String? ownerId,
    String? videoDescription,
    String? aiDescription,
    String? createdAt,
    String? summary,
    List<String>? transcript,
    String? channelName,
    String? videoUploadedDate,
  }) {
    return YoutubeSummaryModel(
      summaryId: summaryId ?? this.summaryId,
      videoTitle: videoTitle ?? this.videoTitle,
      ownerId: ownerId ?? this.ownerId,
      videoDescription: videoDescription ?? this.videoDescription,
      aiDescription: aiDescription ?? this.aiDescription,
      createdAt: createdAt ?? this.createdAt,
      summary: summary ?? this.summary,
      transcript: transcript ?? this.transcript,
      channelName: channelName ?? this.channelName,
      videoUploadedDate: videoUploadedDate ?? this.videoUploadedDate,
    );
  }

 
}