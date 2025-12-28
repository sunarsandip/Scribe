import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:scribe/views/screens/meeting_info/widgets/custom_tab_bar.dart';
import 'package:scribe/views/screens/meeting_info/widgets/meeting_info_widgets.dart';

class MeetingTitle extends StatelessWidget {
  final String meetingTitle;
  final String date;
  final String time;
  final String duration;
  final String description;

  final TabController? tabController;
  const MeetingTitle({
    super.key,
    this.tabController,
    required this.meetingTitle,
    required this.date,
    required this.time,
    required this.duration,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.symmetric(
          horizontal: BorderSide(width: 1, color: AppColors.lightBlackColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.accentColor, AppColors.whiteColor],
              ),
            ),
            child: Text(
              meetingTitle,
              style: AppTextStyles.h2,
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                ReadMoreText(
                  description,
                  style: AppTextStyles.normalText,
                  trimLines: 3,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: "Read More",
                  trimExpandedText: "Read Less",
                  moreStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.iconButtonColor,
                  ),
                  lessStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.redColor,
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MeetingInfoWidgets(
                      icon: Icons.calendar_month_outlined,
                      text: date,
                    ),
                    MeetingInfoWidgets(
                      icon: Icons.watch_later_outlined,
                      text: time,
                    ),
                    MeetingInfoWidgets(
                      icon: Icons.timer_outlined,
                      text: duration,
                    ),
                  ],
                ),
                Divider(),
                CustomTabBar(externalController: tabController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
