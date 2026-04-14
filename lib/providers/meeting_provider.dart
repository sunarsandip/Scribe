
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scribe/controllers/meeting_controller.dart';
import 'package:scribe/providers/user_provider.dart';

final getUserMeetingProvider = StreamProvider((ref) async* {
  final authUser = await ref.watch(authStateProvider.future);
  if (authUser == null) {
    yield* const Stream.empty();
  } else {
    yield* MeetingController().getUserMeetings(authUser.uid);
  }
});

final meetingProcessingProvider = StateProvider<bool>((ref) {
  return false;
});
