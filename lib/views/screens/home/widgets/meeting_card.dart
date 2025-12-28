import 'package:flutter/material.dart';
import 'package:scribe/models/meeting_model.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';

class MeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  final VoidCallback? onTap;

  const MeetingCard({super.key, required this.meeting, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundColor,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              // Header row with title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: AppTextStyles.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Divider(),

              SizedBox(height: 3),
              // Date time info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoIcon(
                    icon: Icons.calendar_today_outlined,
                    text: meeting.formattedDate,
                  ),
                  _buildInfoIcon(
                    icon: Icons.access_time,
                    text: meeting.formattedTime.toString(),
                  ),

                  _buildInfoIcon(
                    icon: Icons.timer_outlined,
                    text: meeting.formattedDuration.toString(),
                  ),
                ],
              ),
              SizedBox(height: 3),

              // Description
              Divider(),
              Text(
                meeting.description,
                style: AppTextStyles.normalText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

           
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoIcon({required IconData icon, required String text}) {
    return Row(
      spacing: 4,
      children: [
        Icon(icon, size: 18, color: AppColors.blackColor),
        Text(text, style: AppTextStyles.normalText),
      ],
    );
  }

 
}
