import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scribe/controllers/recording_controller.dart';
import 'package:scribe/views/screens/features/widgtes/feature_button.dart';
import 'package:scribe/views/screens/features/widgtes/youtube_link_bottom_sheet.dart';

class FeaturesScreen extends StatefulWidget {
  const FeaturesScreen({super.key});

  @override
  State<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen> {
  final recordingController = RecordingController();
  final TextEditingController youtubeLinkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("AI Features"),
            SizedBox(width: 10),
            Image.asset("assets/images/ai_star.png", height: 26, width: 26),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Divider(),
            FeatureButton(
              onTap: () async {
                await recordingController.startRecording();
                context.pushNamed("recording", extra: recordingController);
              },
              image: "assets/images/record.png",
              text: "Live Recording",
              description:
                  "Capture and transcribe conversations in real time, then get a concise summary.",
            ),
            FeatureButton(
              onTap: () {
                showModalBottomSheet(
                  enableDrag: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return YoutubeLinkBottomSheet(
                      linkController: youtubeLinkController,
                    );
                  },
                );
              },
              image: "assets/images/youtube.png",
              text: "YouTube Summary",
              description:
                  "Paste a YouTube link to receive a short, clear summary of the video's content.",
            ),
            FeatureButton(
              onTap: () {},
              image: "assets/images/pdf.png",
              text: "PDF Summary",
              description:
                  "Upload a PDF to extract key points and actionable insights quickly.",
            ),
          ],
        ),
      ),
    );
  }
}