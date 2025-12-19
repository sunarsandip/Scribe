import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    bool isProcessing = ref.watch(meetingProcessingProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.accentColor, AppColors.backgroundColor],
            ),
          ),
        ),
        title: Text(
          'SCRIBE',
          style: AppTextStyles.title.copyWith(
            fontFamily: "Bauhaus",
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.iconButtonColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(getUserMeetingProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                CustomSearchBar(),
                CustomChoiceChip(),
                isProcessing ? MeetingProcessingIndicator() : SizedBox(),
                Consumer(
                  builder: (context, ref, widget) {
                    final data = ref.watch(getUserMeetingProvider);
                    return data.when(
                      data: (meeting) {
                        if (meeting.isNotEmpty) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 8, bottom: 80),
                            itemCount: meeting.length,
                            itemBuilder: (context, index) {
                              final meetingData = meeting[index];

                              return MeetingCard(
                                meeting: MeetingModel(
                                  meetingId: meetingData.meetingId,
                                  title: meetingData.title,
                                  description: meetingData.description,
                                  createdAt: meetingData.createdAt,
                                  duration: meetingData.duration,
                                  summary: meetingData.summary,
                                  toDo: meetingData.toDo,
                                  ownerId: meetingData.ownerId,
                                  audioFilePath: meetingData.ownerId,
                                  fullTranscript: meetingData.fullTranscript,
                                ),
                                onTap: () {
                                  context.pushNamed(
                                    "meetingInfo",
                                    extra: meetingData,
                                  );
                                },
                              );
                            },
                          );
                        } else {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(child: NoMeetingsWidget()),
                          );
                        }
                      },
                      error: (error, stack) {
                        return Center(
                          child: Text("Error loading meeting: $error"),
                        );
                      },
                      loading: () {
                        return Center(child: CircularProgressIndicator());
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}