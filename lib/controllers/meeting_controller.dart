import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:scribe/models/meeting_model.dart';

class MeetingController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // save meeting data in firestore
  Future<String?> saveMeetingInFirestore(MeetingModel newMeeting) async {
    try {
      // Create a new document reference to get the ID
      final docRef = firestore.collection("meetings").doc();
      final meetingId = docRef.id;

      // Update the meeting with the generated ID and update todos with meetingId
      final updatedMeeting = newMeeting.copyWith(
        meetingId: meetingId,
        toDo: newMeeting.toDo
            .map((todo) => todo.copyWith(meetingId: meetingId))
            .toList(),
      );

      // Save to Firestore
      await docRef.set(updatedMeeting.toMap());
      debugPrint("Meeting saved successfully with ID: $meetingId");
      return meetingId;
    } catch (e) {
      debugPrint("Failed to save meeting: $e");
      return null;
    }
  }

  // Get User Meetings
  Stream<List<MeetingModel>> getUserMeetings(String uid) {
    try {
      return firestore
          .collection("meetings")
          .where("ownerId", isEqualTo: uid)
          .snapshots()
          .map((querySanpshot) {
            return querySanpshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data();
              data['id'] = doc.id;
              return MeetingModel.fromMap(data);
            }).toList();
          });
    } catch (e) {
      debugPrint("Failed to get meetings:$e");
      return Stream.value([]);
    }
  }

  // delete meeting
  Future<Map<String, dynamic>> deleteMeeting(String meetingId) async {
    try {
      firestore.collection("meetings").doc(meetingId).delete();
      return {"success": true, "message": "Meeting deleted successfully!"};
    } catch (e) {
      debugPrint("Failed to delete meeting : $e");
      return {"success": false, "message": "Failed to delete meeting: $e"};
    }
  }

  // Update meeting
  Future<Map<String, dynamic>> updateMeeting(
    String meetingId,
    MeetingModel updatedMeeting,
  ) async {
    try {
      firestore
          .collection("meetings")
          .doc(meetingId)
          .update(updatedMeeting.toMap());
      return {"success": true, "message": "Meeting updated successfully !"};
    } catch (e) {
      debugPrint("Failed to update meeting: $e");
      return {"success": false, "message": "Failed to update meeting !"};
    }
  }
  // Get a single meeting by ID
  Future<MeetingModel?> getMeetingById(String meetingId) async {
    try {
      final doc = await firestore.collection("meetings").doc(meetingId).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = doc.id;
      return MeetingModel.fromMap(data);
    } catch (e) {
      debugPrint("Failed to fetch meeting by id: $e");
      return null;
    }
  }

 
}