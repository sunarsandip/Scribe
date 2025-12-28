import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:scribe/controllers/youtube_summary_controller.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:scribe/views/widgets/primary_button.dart';
import 'package:scribe/views/widgets/primary_text_field.dart';

class YoutubeLinkBottomSheet extends StatefulWidget {
  final TextEditingController linkController;
  const YoutubeLinkBottomSheet({super.key, required this.linkController});

  @override
  State<YoutubeLinkBottomSheet> createState() => _YoutubeLinkBottomSheetState();
}

class _YoutubeLinkBottomSheetState extends State<YoutubeLinkBottomSheet> {
  late YoutubeSummaryController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubeSummaryController();
  }

  Future<void> _generateSummary() async {
    final url = widget.linkController.text.trim();

    if (url.isEmpty) {
      _showErrorSnackbar('Please enter a YouTube URL');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _controller.generateYoutubeSummary(url);

      if (!mounted) return;

      if (result['success'] == true) {
        _showSuccessSnackbar(result['message'] ?? 'Summary generated!');
        // Close bottom sheet after success
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        _showErrorSnackbar(result['message'] ?? 'Failed to generate summary');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 12),
        height: mq.height * 0.32,
        width: mq.width,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Divider(
              indent: 120,
              endIndent: 120,
              thickness: 4,
              radius: BorderRadius.circular(10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Image.asset("assets/images/youtube.png", width: 28),
                Text("YouTube Summary", style: AppTextStyles.title),
              ],
            ),
            PrimaryTextField(
              hintText: "Video Link",
              controller: widget.linkController,
              prefixIcon: FeatherIcons.link,
            ),
            Text(
              "Copy video URL that you want the summary of from youtube and just paste here",
              style: AppTextStyles.smallText,
            ),
            Spacer(),
            PrimaryButton(
              height: 50,
              text: _isLoading ? "Generating..." : "Generate Summary",
              backgroundColor: AppColors.blackColor,
              textColor: AppColors.whiteColor,
              textStyle: AppTextStyles.normalText,
              isLoading: _isLoading,
              onTap: _generateSummary,
            ),
          ],
        ),
      ),
    );
  }
}
