import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scribe/controllers/meeting_controller.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/user_feedback/user_feedback.dart';
import 'package:scribe/models/meeting_model.dart';
import 'package:scribe/views/screens/meeting_info/widgets/edit_meeting_bottom_sheet.dart';
import 'package:scribe/views/screens/meeting_info/widgets/meeting_popup_menu.dart';
import 'package:scribe/views/screens/meeting_info/widgets/summary_widget.dart';
import 'package:scribe/views/screens/meeting_info/widgets/meeting_title.dart';
import 'package:scribe/views/screens/meeting_info/widgets/todo_widget.dart';
import 'package:scribe/views/screens/meeting_info/widgets/transcript_widget.dart';

class MeetingInfoScreen extends StatefulWidget {
  final MeetingModel meetingData;

  const MeetingInfoScreen.MeetingInfoScreen({
    super.key,
    required this.meetingData,
  });

  @override
  State<MeetingInfoScreen> createState() => _MeetingInfoScreenState();
}

class _MeetingInfoScreenState extends State<MeetingInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MeetingModel _meetingData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _meetingData = widget.meetingData;
  }

  Future<void> _reloadMeeting() async {
    final updated = await MeetingController().getMeetingById(
      _meetingData.meetingId,
    );
    if (updated != null) {
      setState(() {
        _meetingData = updated;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        actions: [
          MeetingPopupMenu(
            onDelete: () async {
              UserFeedback.showCustomDialog(
                context: context,
                title: "Delete",
                description: "Once deleted, Cannot Undo!",
                confirmText: "Delete",
                onConfirm: () async {
                  final res = await MeetingController().deleteMeeting(
                    widget.meetingData.meetingId,
                  );
                  if (res["success"]) {
                    UserFeedback.showInfoSnackbar(context, "${res["message"]}");
                    context.goNamed("mainScreen");
                  } else {
                    UserFeedback.showErrorSnackbar(
                      context,
                      "${res["message"]}",
                    );
                  }
                },
                onCancel: () {
                  context.pop();
                },
              );
            },
            onEdit: () async {
              EditMeetingBottomSheet.showEditMeetingBottomSheet(
                context,
                meeting: _meetingData,
              );
              await _reloadMeeting();
            },
            onShare: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            MeetingTitle(
              tabController: _tabController,
              meetingTitle: _meetingData.title,
              date: _meetingData.formattedDate,
              time: _meetingData.formattedTime,
              duration: _meetingData.formattedDuration,
              description: _meetingData.description,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SummaryWidget(summary: _meetingData.summary),
                  TodoWidget(
                    todo: _meetingData.toDo,
                    meetingId: _meetingData.meetingId,
                    onIsCompletedToggled: _reloadMeeting,
                  ),
                  TranscriptWidget(
                    transcript: _meetingData.fullTranscript,
                    audioUrl: _meetingData.audioFilePath,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}