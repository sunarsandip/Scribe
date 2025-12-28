import 'dart:convert';
import 'package:scribe/helpers/date_time_formatting_helper.dart';
import 'package:scribe/models/todo_model.dart';

class MeetingModel {
  final String meetingId;
  final String ownerId;
  final String title;
  final String description;
  final DateTime createdAt;
  final Duration duration;
  final String summary;
  final List<TodoModel> toDo;
  final String audioFilePath;
  final String fullTranscript;

  MeetingModel({
    required this.meetingId,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.duration,
    required this.summary,
    required this.toDo,
    required this.audioFilePath,
    required this.fullTranscript,
  });

  MeetingModel copyWith({
    String? meetingId,
    String? ownerId,
    String? title,
    String? description,
    DateTime? createdAt,
    Duration? duration,
    String? summary,
    List<TodoModel>? toDo,
    String? audioFilePath,
    String? fullTranscript,
  }) {
    return MeetingModel(
      meetingId: meetingId ?? this.meetingId,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      summary: summary ?? this.summary,
      toDo: toDo ?? this.toDo,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      fullTranscript: fullTranscript ?? this.fullTranscript,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': meetingId,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'duration': duration.inMilliseconds,
      'summary': summary,
      'toDo': toDo.map((x) => x.toMap()).toList(),
      'audioFilePath': audioFilePath,
      'fullTranscript': fullTranscript,
    };
  }

  factory MeetingModel.fromMap(Map<String, dynamic> map) {
    return MeetingModel(
      meetingId: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      duration: Duration(milliseconds: map['duration'] ?? 0),
      summary: map['summary'] ?? '',
      toDo: List<TodoModel>.from(map['toDo']?.map((x) => TodoModel.fromMap(x))),
      audioFilePath: map['audioFilePath'] ?? '',
      fullTranscript: map['fullTranscript'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory MeetingModel.fromJson(String source) =>
      MeetingModel.fromMap(json.decode(source));

  // formatting method 
  String get formattedDate => DateTimeFormattingHelper.formatDate(createdAt);
  String get formattedTime => DateTimeFormattingHelper.formatTime(createdAt);
  String get formattedDuration =>
      DateTimeFormattingHelper.formattedDuration(duration);
}