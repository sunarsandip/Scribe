import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scribe/controllers/meeting_controller.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:scribe/core/user_feedback/user_feedback.dart';
import 'package:scribe/models/meeting_model.dart';
import 'package:scribe/providers/meeting_provider.dart';
import 'package:scribe/views/widgets/primary_button_with_icon.dart';

class EditMeetingBottomSheet {
  static Future<void> showEditMeetingBottomSheet(
    BuildContext context, {
    required MeetingModel meeting,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EditMeetingBottomSheetContent(meeting: meeting),
    );
  }
}

class _EditMeetingBottomSheetContent extends ConsumerStatefulWidget {
  final MeetingModel meeting;

  const _EditMeetingBottomSheetContent({required this.meeting});

  @override
  ConsumerState<_EditMeetingBottomSheetContent> createState() =>
      _EditMeetingBottomSheetContentState();
}

class _EditMeetingBottomSheetContentState
    extends ConsumerState<_EditMeetingBottomSheetContent> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController summaryController;
  late final TextEditingController durationController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.meeting.title);
    descriptionController = TextEditingController(
      text: widget.meeting.description,
    );
    summaryController = TextEditingController(text: widget.meeting.summary);
    durationController = TextEditingController(
      text: widget.meeting.formattedDuration,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    summaryController.dispose();
    durationController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag holder
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightBlackColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            SizedBox(height: 12),
            Text('Edit Meeting', style: AppTextStyles.title),
            SizedBox(height: 12),

            TextField(
              controller: titleController,
              maxLines: null,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            SizedBox(height: 8),
            TextField(
              controller: summaryController,
              decoration: InputDecoration(labelText: 'Summary'),
              maxLines: 4,
            ),
            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.normalText.copyWith(
                      color: AppColors.textButtonColor,
                    ),
                  ),
                ),

                // save button
                PrimaryButtonWithIcon(
                  isLoading: _isLoading,
                  text: "Save",
                  backgroundColor: AppColors.iconButtonColor,
                  foregroundColor: AppColors.whiteColor,
                  onTap: () async {
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      final res = await MeetingController().updateMeeting(
                        widget.meeting.meetingId,
                        widget.meeting.copyWith(
                          title: titleController.text,
                          description: descriptionController.text,
                          summary: summaryController.text,
                        ),
                      );
                      if (res["success"]) {
                        ref.invalidate(getUserMeetingProvider);
                        context.pop();
                        UserFeedback.showSuccessSnackbar(
                          context,
                          "Meeting updated Successfully",
                        );
                      } else {
                        UserFeedback.showErrorSnackbar(
                          context,
                          "Failed to Update Meeting: ${res["message"]}",
                        );
                      }
                    } catch (e) {
                      UserFeedback.showErrorSnackbar(
                        context,
                        "Failed to update meeting: $e",
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  icon: Icons.check,
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
